import Foundation

class AppState {

    static let shared = AppState()

    private let networkMonitor = NetworkMonitor()
    private let connectivityChecker = ConnectivityChecker()

    private var refreshTimer: Timer?
    private var debounceTimer: Timer?

    enum ConnectionStatus {
        case connected
        case blocked
        case noNetwork
    }

    struct ConnectionSnapshot {
        let overallStatus: ConnectionStatus
        let siteStatuses: [ConnectionStatus]
    }

    var statusUpdateHandler: ((ConnectionSnapshot) -> Void)?

    var checkNowResultHandler: ((ConnectionSnapshot) -> Void)?

    var refreshInterval: TimeInterval {
        let saved = UserDefaults.standard.double(forKey: "refreshInterval")
        return saved == 0 ? 30 : saved
    }

    // MARK: - Public Start

    func start() {

        // Listen for network interface changes (WiFi off, Ethernet unplugged)
        networkMonitor.pathChangedHandler = { [weak self] in
            self?.debouncedImmediateCheck()
        }

        networkMonitor.startMonitoring()

        startTimer()

        // Immediate outbound attempt on startup
        checkConnection()
    }

    // MARK: - Restart (when settings change)

    func restart() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        startTimer()
        checkConnection()
    }

    // MARK: - Immediate check (bypasses interval, triggered on demand)

    func checkNow() {
        checkConnection(onDemand: true)
    }

    // MARK: - Timer

    private func startTimer() {

        refreshTimer?.invalidate()

        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkConnection()
        }
    }

    // MARK: - Debounce for rapid network changes

    private func debouncedImmediateCheck() {

        debounceTimer?.invalidate()

        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: false
        ) { [weak self] _ in
            self?.checkConnection()
        }
    }

    // MARK: - Core Logic

    private func checkConnection(onDemand: Bool = false) {
        let targetCount = ConnectivityChecker.monitoringURLStrings.count

        if !networkMonitor.isConnected {
            let snapshot = ConnectionSnapshot(
                overallStatus: .noNetwork,
                siteStatuses: Array(repeating: .noNetwork, count: targetCount)
            )
            statusUpdateHandler?(snapshot)
            if onDemand { checkNowResultHandler?(snapshot) }
            return
        }

        connectivityChecker.checkOutboundConnections { [weak self] reachableSites in
            DispatchQueue.main.async {
                let siteStatuses = reachableSites.map { $0 ? ConnectionStatus.connected : .blocked }
                let overallStatus: ConnectionStatus = siteStatuses.allSatisfy { $0 == .connected } ? .connected : .blocked
                let snapshot = ConnectionSnapshot(overallStatus: overallStatus, siteStatuses: siteStatuses)
                self?.statusUpdateHandler?(snapshot)
                if onDemand { self?.checkNowResultHandler?(snapshot) }
            }
        }
    }
}
