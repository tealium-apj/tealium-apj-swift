import Foundation
import TealiumSwift

final class TealiumHelper {

    static let shared = TealiumHelper()

    private(set) var tealium: Tealium?
    private var config: TealiumConfig?

    // Flip this to true when the Firebase JSON remote command actually executes
    private(set) var firebaseJsonConfigWasUsed: Bool = false

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
        logLevel=\(config.logLevel)
        firebaseJsonUsed=\(firebaseJsonConfigWasUsed)
        """
    }

    // MARK: - Private

    private init() {
        initTealium()
    }

    private func initTealium() {
        // 1. Base config with your account/profile/env
        let config = TealiumConfig(
            account:    "housing.com",
            profile:    "main",
            environment:"dev",
            dataSource: "sj4tup"   // TODO: replace with your real CDH data source key
        )

        // 2. Enable Collect + RemoteCommands dispatchers
        config.dispatchers = [
            Dispatchers.Collect,
            Dispatchers.RemoteCommands,
            Dispatchers.TagManagement
        ]

        // Optional explicit collectors (or omit to use defaults)
        config.collectors = [
            Collectors.AppData,
            Collectors.Device,
            Collectors.Connectivity,
            Collectors.Lifecycle
        ]

        // IMPORTANT: leave Mobile Publish Settings alone (use Tealium defaults).
        // Do NOT set publishSettingsURL to the Firebase JSON.

        // 3. Enable verbose logging so you can still see network/log detail
        config.logLevel = .debug

        // 4. Initialize Tealium
        self.config = config
        tealium = Tealium(config: config) { [weak self] _ in
            guard let self else { return }

            print("[Tealium] Initialization completed.")

            // 5. After init, register a RemoteCommand that loads JSON from Firebase
            self.setupFirebaseRemoteCommand()

            // 6. Fire a test event that should trigger a command from that JSON
            // (depends on how you configured commands section in the JSON)
            let testEvent = TealiumEvent(
                "firebase_rc_test",
                dataLayer: [
                    "sdk_source": "ios_swift_sample"
                ]
            )
            self.tealium?.track(testEvent)
            print("[Tealium] Sent test event 'firebase_rc_test' after registering Firebase RC.")
        }
    }

    /// Registers a RemoteCommand that loads its config JSON from Firebase.
    private func setupFirebaseRemoteCommand() {
        guard let remoteCommands = tealium?.remoteCommands else {
            print("[Tealium] RemoteCommands module not available.")
            return
        }

        //let firebaseJsonUrl = "https://firebasestorage.googleapis.com/v0/b/skilful-racer-95713.appspot.com/o/Tealium%2Ffirebase_remote_commands?alt=media"
        let firebaseJsonUrl = "https://firebasestorage.googleapis.com/v0/b/river-oxygen-792.appspot.com/o/Tealium%2Ffirebase_remote_commands?alt=media&token=5ded980f-6aca-4f3c-9d04-abab4645331e"
        
        let firebaseRemoteCommand = RemoteCommand(
            commandId: "firebase_remote",
            description: "Firebase remote commands JSON",
            type: .remote(url: firebaseJsonUrl)
        ) { [weak self] response in
            guard let self else { return }

            self.firebaseJsonConfigWasUsed = true

            let payload = response.payload ?? [:]
            print("[Firebase RC] Remote JSON command executed with payload: \(payload)")
            print("[Firebase RC] -> This proves the JSON at \(firebaseJsonUrl) was fetched and parsed.")
        }

        remoteCommands.add(firebaseRemoteCommand)
        print("[Tealium] Firebase RemoteCommand registered with URL: \(firebaseJsonUrl)")
    }
}
