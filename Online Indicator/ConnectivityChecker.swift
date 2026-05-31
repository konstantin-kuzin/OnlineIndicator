import Foundation

class ConnectivityChecker {

    static let defaultURLString = "http://captive.apple.com"
    static let monitoringURLsKey = "pingURLs"
    static let monitoringURLAliasesKey = "pingURLAliases"
    static let legacyMonitoringURLKey = "pingURL"
    static let maximumMonitoringURLCount = 3

    static var monitoringURLStrings: [String] {
        let stored = storedMonitoringURLStrings()
        return stored.isEmpty ? [defaultURLString] : stored
    }

    static func editableMonitoringURLStrings() -> [String] {
        var urls = storedMonitoringURLStrings()
        if urls.count < maximumMonitoringURLCount {
            urls.append(contentsOf: Array(repeating: "", count: maximumMonitoringURLCount - urls.count))
        }
        return Array(urls.prefix(maximumMonitoringURLCount))
    }

    static func editableMonitoringURLAliases() -> [String] {
        var aliases = storedMonitoringURLAliases()
        if aliases.count < maximumMonitoringURLCount {
            aliases.append(contentsOf: Array(repeating: "", count: maximumMonitoringURLCount - aliases.count))
        }
        return Array(aliases.prefix(maximumMonitoringURLCount))
    }

    static var monitoringDisplayNames: [String] {
        let urls = monitoringURLStrings
        let aliases = storedMonitoringURLAliases()
        return urls.enumerated().map { index, url in
            let alias = index < aliases.count ? aliases[index] : ""
            return alias.isEmpty ? url : alias
        }
    }

    static func saveMonitoringTargets(urls candidates: [String], aliases aliasCandidates: [String]) {
        let normalized = normalizedMonitoringURLStrings(from: candidates)
        UserDefaults.standard.removeObject(forKey: legacyMonitoringURLKey)

        if normalized.isEmpty {
            UserDefaults.standard.removeObject(forKey: monitoringURLsKey)
            UserDefaults.standard.removeObject(forKey: monitoringURLAliasesKey)
            return
        }

        UserDefaults.standard.set(normalized, forKey: monitoringURLsKey)

        let normalizedAliases = Array(
            aliasCandidates
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .prefix(normalized.count)
        )
        UserDefaults.standard.set(normalizedAliases, forKey: monitoringURLAliasesKey)
    }

    static func normalizedMonitoringURLStrings(from candidates: [String]) -> [String] {
        Array(
            candidates
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .prefix(maximumMonitoringURLCount)
        )
    }

    static func invalidMonitoringURLIndexes(in candidates: [String]) -> Set<Int> {
        Set(
            candidates.enumerated().compactMap { index, candidate in
                let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return isValidMonitoringURL(trimmed) ? nil : index
            }
        )
    }

    static func isValidMonitoringURL(_ candidate: String) -> Bool {
        guard let url = URL(string: candidate),
              let scheme = url.scheme?.lowercased() else { return false }
        return ["http", "https"].contains(scheme)
    }

    private static func storedMonitoringURLStrings() -> [String] {
        if let saved = UserDefaults.standard.array(forKey: monitoringURLsKey) as? [String] {
            return normalizedMonitoringURLStrings(from: saved)
        }

        let legacy = UserDefaults.standard.string(forKey: legacyMonitoringURLKey) ?? ""
        return normalizedMonitoringURLStrings(from: [legacy])
    }

    private static func storedMonitoringURLAliases() -> [String] {
        guard let saved = UserDefaults.standard.array(forKey: monitoringURLAliasesKey) as? [String] else {
            return []
        }

        return Array(
            saved
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .prefix(maximumMonitoringURLCount)
        )
    }

    private let stateQueue = DispatchQueue(label: "ConnectivityChecker.StateQueue")
    private var currentTasks: [URLSessionDataTask] = []
    private var activeCheckID = UUID()

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.httpAdditionalHeaders = ["Connection": "close"]
        return URLSession(configuration: configuration)
    }()

    func checkOutboundConnections(completion: @escaping ([Bool]) -> Void) {
        let targets = Self.monitoringURLStrings
        print("Attempting outbound connections to:", targets.joined(separator: ", "))

        let checkID = UUID()
        stateQueue.sync {
            activeCheckID = checkID
            currentTasks.forEach { $0.cancel() }
            currentTasks.removeAll()
        }

        let group = DispatchGroup()
        let lock = NSLock()
        var results = Array(repeating: false, count: targets.count)

        for (index, target) in targets.enumerated() {
            guard let url = URL(string: target) else { continue }

            group.enter()

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 5

            let task = session.dataTask(with: request) { _, response, error in
                defer { group.leave() }

                if let urlError = error as? URLError, urlError.code == .cancelled {
                    return
                }

                if let error = error {
                    if let urlError = error as? URLError, urlError.code == .timedOut {
                        print("Connection check timed out [\(target)] after 5 seconds.")
                    } else {
                        print("Connection check failed [\(target)]: \(error.localizedDescription)")
                    }
                    return
                }

                let reachable = (response as? HTTPURLResponse).map { (200...399).contains($0.statusCode) } ?? false

                lock.lock()
                results[index] = reachable
                lock.unlock()

            }

            stateQueue.sync {
                currentTasks.append(task)
            }
            task.resume()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }

            let isActiveCheck = self.stateQueue.sync { self.activeCheckID == checkID }
            guard isActiveCheck else { return }

            self.stateQueue.async {
                self.currentTasks.removeAll()
            }

            completion(results)
        }
    }
}
