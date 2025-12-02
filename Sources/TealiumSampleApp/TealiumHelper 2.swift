import Foundation
import TealiumSwift   // Umbrella for TealiumCore, Collect, RemoteCommands, etc.

final class TealiumHelper {

    static let shared = TealiumHelper()

    private(set) var tealium: Tealium?
    private var config: TealiumConfig?

    // MARK: - Public API

    func start() {
        _ = TealiumHelper.shared
    }

    func track(event name: String, data: [String: Any]?) {
        guard let tealium = tealium else {
            print("[TealiumHelper] Tealium not initialized yet – dropping event \(name)")
            return
        }

        let tealEvent = TealiumEvent(name, dataLayer: data)
        tealium.track(tealEvent)
        print("[TealiumHelper] Tracked event: \(name) with data: \(data ?? [:])")
    }

    var debugConfigSummary: String {
        guard let config else { return "Config not initialized" }
        return """
        dispatchers=\(config.dispatchers)
        publishSettingsURL=\(config.publishSettingsURL ?? "nil")
        logLevel=\(config.logLevel)
        """
    }

    // MARK: - Private

    private init() {
        initTealium()
    }

    private func initTealium() {
        // 1. Your Tealium account/profile/environment
        let config = TealiumConfig(
            account:    "success-ryunosuke-senda",
            profile:    "mobile-test",
            environment:"prod",
            dataSource: "DATASOURCE"   // TODO: replace with your real CDH data source key
        )

        // 2. Enable Collect + RemoteCommands dispatchers
        config.dispatchers = [
            Dispatchers.Collect,
            Dispatchers.RemoteCommands
        ]

        // Optional explicit collectors (or omit to use defaults)
        config.collectors = [
            Collectors.AppData,
            Collectors.Device,
            Collectors.Connectivity,
            Collectors.Lifecycle
        ]

        // 3. Use Mobile Publish Settings from your Firebase URL
        config.shouldUseRemotePublishSettings = true
        config.publishSettingsURL = "https://firebasestorage.googleapis.com/v0/b/skilful-racer-95713.appspot.com/o/Tealium%2Ffirebase_remote_commands?alt=media"

        // 4. Verbose logging
        config.logLevel = .debug

        // 5. Simple Remote Command to prove RC dispatcher is working
        #if os(iOS)
        let testRemoteCommand = RemoteCommand(
            commandId: "hello_world",
            description: "Test Remote Command"
        ) { response in
            print("[Tealium RC] Command 'hello_world' executed")

            if let payload = response.payload {
                print("[Tealium RC] Payload: \(payload)")
            } else {
                print("[Tealium RC] No payload received")
            }
        }

        config.addRemoteCommand(testRemoteCommand)
        #endif

        self.config = config

        // 6. Initialize Tealium
        tealium = Tealium(config: config) { [weak self] _ in
            guard let self, let instance = self.tealium else { return }

            print("[Tealium] Initialization completed.")
            print("[Tealium] Dispatchers: \(config.dispatchers)")
            print("[Tealium] Collect enabled: \(config.isCollectEnabled)")
            print("[Tealium] Publish settings URL: \(config.publishSettingsURL ?? "nil")")

            // 7. Fire a test event so you can see everything in logs
            let testEvent = TealiumEvent(
                "firebase_config_test",
                dataLayer: [
                    "config_source": "firebase_publish_settings",
                    "example_flag":  true
                ]
            )
            instance.track(testEvent)
            print("[Tealium] Sent test event 'firebase_config_test' after init.")

            if let vid = instance.visitorId {
                print("[Tealium] Current visitorId: \(vid)")
            } else {
                print("[Tealium] visitorId is nil (may still be initializing)")
            }
        }
    }
}