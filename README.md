<p align="center">
  <img src=".github/assets/app-icon.png" alt="Online Indicator" width="120" />
</p>

<h1 align="center">Online Indicator</h1>

<p align="center">
A macOS menu bar app that replaces the Wi-Fi icon with customizable status indicators.
</p>
<br>
<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/platform-macOS-lightgrey?logo=apple&style=flat&color=%23FF5C60"></a>
  <a href="https://github.com/konstantin-kuzin/OnlineIndicator/releases" target="_blank"><img src="https://img.shields.io/github/v/release/konstantin-kuzin/OnlineIndicator?style=flat&color=%23FAC800"></a>
  <a href="https://github.com/konstantin-kuzin/OnlineIndicator/blob/main/LICENSE" target="_blank"><img src="https://img.shields.io/github/license/konstantin-kuzin/OnlineIndicator?style=flat&color=%2334C759"></a>
</p>
<br>

## Update · v1.5

- **Three monitoring domains** — configure up to three URLs to check on every cycle, so you can verify connectivity against multiple endpoints at once. For example, with split-tunnel VPN you can monitor general internet access, VPN reachability, and access to a corporate network segment — each with its own endpoint and status.
- **New multi-bar indicator** — when more than one domain is active, the menu bar icon switches to a compact bar view with a separate colored segment for each domain, making per-site status visible at a glance.
- **Domain aliases** — assign a short friendly name to each monitoring URL; aliases appear in status popovers and blocked-state messages instead of the raw address.

<br>

<img src=".github/assets/app-preview.png" alt="Online Indicator Preview" width="100%" />

## Why Online Indicator?

The macOS WiFi icon only shows that you are connected to a router, not whether your internet is actually working or being blocked. Online Indicator replaces it with a live status icon that verifies real internet connectivity at the network level, so you can instantly see if you are online, offline, or blocked without opening any apps, giving you a smarter and slightly geekier way to understand your connection at a glance.

<br>

## Features

<img src=".github/assets/wifi.png" height="32" height="32" /><br>
**Ditch The Boring Wi-Fi Icon** <br>
Online Indicator brings a smarter network experience to your menu bar with a live status icon that clearly shows your connection and gives you quick access to Wi Fi controls and settings.

<img src=".github/assets/palette.png" height="32" height="32" /><br>
**Make Every State Completely Yours!** <br>
Choose from 17 ready made Icon Sets or use any SF Symbol, set custom colors and labels for each state, and save your setup as your own Icon Set to switch anytime with a single tap.

<img src=".github/assets/icon.png" height="32" height="32" /><br>
**Your Icon, Your Rules.** <br>
Why should a menu bar icon only ever do one thing? With Online Indicator, your left and right clicks each perform different actions and you can decide which does what. Swap them if the defaults do not feel right or disable custom actions entirely and just use the dropdown. You are always in control.

<img src=".github/assets/bolt.png" height="32" height="32" /><br>
**Fast and Simple Network Control** <br>
Control your Wi Fi connection and access network settings directly from the menu with a single click. Instantly view your current IP address with live updates and copy it to your clipboard for quick and easy sharing without needing additional tools or steps. For a more minimal and clean menu, the IP address display can also be turned off.

<img src=".github/assets/monitor.png" height="32" height="32" /><br>
**Flexible monitoring** <br>
Decide how often Online Indicator checks your network by using the default presets or set your own custom interval. By default it pings Apple’s captive portal server, but you can point it to any URL you trust, whether your own server, company endpoint, or a custom address, ensuring reliable and flexible connectivity monitoring.

<img src=".github/assets/peek.png" height="32" height="32" /><br>
**Quick IP peek** <br>
Your IPv4 and IPv6 are always one click away in the menu. Tap to copy instantly, or hide them for a cleaner look.

<img src=".github/assets/keyboard.png" height="32" height="32" /><br>
**Keyboard Shortcuts** <br>
Set custom keyboard shortcuts to quickly toggle Wi Fi, open Wi Fi settings, and access network settings giving you faster control over your connectivity.

<br>

## Download & Install

### 1 · Download
Head to the [**Latest Release**](../../releases/latest) page and grab the latest `.dmg` file.

### 2 · Install
Open the `.dmg` and drag **Online Indicator** into your **Applications** folder. Done.

### 3 · First Launch

#### Option A — System Settings

1. Go to **System Settings → Privacy & Security**
2. Scroll down until you see Online Indicator listed as blocked
3. Click **Open Anyway** and enter your password

#### Option B — Terminal

Paste this into Terminal and press Enter:
```bash
xattr -dr com.apple.quarantine /Applications/Online\ Indicator.app
```
Then open the app normally.

> 💡 **Why does this happen?**
> Apple requires a $99/year developer certificate to "notarise" apps. Online Indicator is free and independent, so it skips that. The warning is Apple's way of flagging uncertified apps, not a sign that anything is wrong.

<br>

## Privacy Policy

Online Indicator collects no data. Period.

- No analytics, crash reporting or usage tracking
- No personal information collected or transmitted
- All preferences are stored locally on your Mac

The only outbound network request the app makes is the connectivity probe, a simple HTTP request to `captive.apple.com` (or your custom URL) to check if the internet is reachable. This is identical to what macOS itself does internally.

<br>

## License

[MIT License](LICENSE)
