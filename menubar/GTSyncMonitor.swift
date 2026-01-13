#!/usr/bin/env swift
//
// Gas Town Auto-Sync Menu Bar Monitor
// Native Swift implementation (no dependencies)
//
// To compile:
//   swiftc -o GTSyncMonitor GTSyncMonitor.swift
//
// To run:
//   ./GTSyncMonitor
//
// To auto-start on login:
//   Copy compiled binary to ~/gt/bin/
//   Create launchd plist (see MENUBAR.md)

import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    let logFilePath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("gt/logs/auto-sync.log")
    let controlScript = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("gt/bin/gt-sync-control")

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "🚀"
        }

        // Create menu
        let menu = NSMenu()
        statusItem.menu = menu

        // Update immediately and then every 30 seconds
        updateStatus()
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.updateStatus()
        }
    }

    func updateStatus() {
        guard let button = statusItem.button else { return }
        let menu = NSMenu()

        // Check if daemon is running
        let daemonRunning = isDaemonRunning()

        if !daemonRunning {
            button.title = "🚀❌"
            menu.addItem(NSMenuItem(title: "❌ Daemon NOT Running", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())

            let startItem = NSMenuItem(title: "Start Daemon", action: #selector(startDaemon), keyEquivalent: "")
            startItem.target = self
            menu.addItem(startItem)

            statusItem.menu = menu
            return
        }

        // Parse log file
        let stats = parseLogFile()

        // Determine status
        var icon = "🚀"
        var status = "All systems operational"

        if stats.recentAttempts > 0 && stats.recentFailures >= 3 {
            // Grey: Multiple recent failures
            button.title = "🚀"
            if let button = statusItem.button {
                button.attributedTitle = NSAttributedString(
                    string: "🚀",
                    attributes: [.foregroundColor: NSColor.systemGray]
                )
            }
            status = "Multiple recent failures"
        } else if stats.failures24h > 0 {
            // Orange: Some failures in 24h
            button.title = "🚀"
            if let button = statusItem.button {
                button.attributedTitle = NSAttributedString(
                    string: "🚀",
                    attributes: [.foregroundColor: NSColor.systemOrange]
                )
            }
            status = "Failures in last 24 hours"
        } else {
            // Green: All good
            button.title = "🚀"
            if let button = statusItem.button {
                button.attributedTitle = NSAttributedString(
                    string: "🚀",
                    attributes: [.foregroundColor: NSColor.systemGreen]
                )
            }
        }

        // Build menu
        menu.addItem(NSMenuItem(title: "Gas Town Auto-Sync", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Status: \(status)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "📊 Statistics", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "  Last Sync: \(stats.lastSync)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "  Recent Attempts: \(stats.recentAttempts)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "  Recent Failures: \(stats.recentFailures)/10", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "  Failures (24h): \(stats.failures24h)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        // Controls
        menu.addItem(NSMenuItem(title: "🔧 Controls", action: nil, keyEquivalent: ""))

        let restartItem = NSMenuItem(title: "Restart Daemon", action: #selector(restartDaemon), keyEquivalent: "")
        restartItem.target = self
        menu.addItem(restartItem)

        let stopItem = NSMenuItem(title: "Stop Daemon", action: #selector(stopDaemon), keyEquivalent: "")
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(NSMenuItem.separator())

        // Logs
        let viewLogsItem = NSMenuItem(title: "View Logs", action: #selector(viewLogs), keyEquivalent: "")
        viewLogsItem.target = self
        menu.addItem(viewLogsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func isDaemonRunning() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        process.arguments = ["-f", "gt-auto-sync"]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    struct LogStats {
        var lastSync: String
        var recentAttempts: Int
        var recentFailures: Int
        var failures24h: Int
    }

    func parseLogFile() -> LogStats {
        var stats = LogStats(lastSync: "Never", recentAttempts: 0, recentFailures: 0, failures24h: 0)

        guard let content = try? String(contentsOf: logFilePath) else {
            return stats
        }

        let lines = content.components(separatedBy: .newlines)
        let syncLines = lines.filter { $0.contains("📤") || $0.contains("✅") || $0.contains("❌") }

        // Recent stats (last 20 lines)
        let recentLines = Array(syncLines.suffix(20))
        stats.recentAttempts = recentLines.filter { $0.contains("📤") }.count
        stats.recentFailures = recentLines.filter { $0.contains("❌") }.count

        // Last sync time
        if let lastPush = syncLines.last(where: { $0.contains("📤") }) {
            let pattern = #"\[([^\]]+)\]"#
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: lastPush, range: NSRange(lastPush.startIndex..., in: lastPush)),
               let range = Range(match.range(at: 1), in: lastPush) {
                stats.lastSync = String(lastPush[range])
            }
        }

        // Failures in last 24 hours
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .hour, value: -24, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for line in syncLines.suffix(100) where line.contains("❌") {
            let pattern = #"\[([^\]]+)\]"#
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line),
               let date = dateFormatter.date(from: String(line[range])),
               date > cutoff {
                stats.failures24h += 1
            }
        }

        return stats
    }

    @objc func startDaemon() {
        runControlScript("start")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateStatus()
        }
    }

    @objc func restartDaemon() {
        runControlScript("restart")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateStatus()
        }
    }

    @objc func stopDaemon() {
        runControlScript("stop")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.updateStatus()
        }
    }

    @objc func viewLogs() {
        NSWorkspace.shared.open(logFilePath)
    }

    func runControlScript(_ command: String) {
        let process = Process()
        process.executableURL = controlScript
        process.arguments = [command]
        try? process.run()
    }
}
