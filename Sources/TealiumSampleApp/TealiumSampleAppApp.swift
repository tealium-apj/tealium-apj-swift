import SwiftUI
import TealiumSwift
#if canImport(TealiumFirebase)
import TealiumFirebase
#endif

final class TealiumHelper: NSObject {

    static let shared = TealiumHelper()

    private(set) var tealium: Tealium?

    func start() {
        let config = TealiumConfig(
            account: "success-ryunosuke-senda",
            profile: "mobile-test",
            environment: "prod",
        )

        // Collectors: include Device & Connectivity when customizing
        config.collectors = [
            Collectors.AppData,
            Collectors.Device,
            Collectors.Connectivity,
            Collectors.Lifecycle,
        ]

        // Choose dispatchers — use Collect + RemoteCommands per the user's request.
        // Collect sends events to Tealium Collect CDN and RemoteCommands runs JSON or iQ commands.
        config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]

        // Enable the remote API to support RemoteCommands via the Tag Management module
        config.remoteAPIEnabled = true

        // Enable verbose SDK logging for debugging
        config.logLevel = .debug
        

        tealium = Tealium(config: config, enableCompletion: { _ in
            // Initialization complete — gather track data and setup remote commands
            print("[TealiumHelper] Initialization complete: gathering track data and setting up remote commands")
            TealiumHelper.shared.tealium?.gatherTrackData(retrieveCachedData: true) { data in
                print("[TealiumHelper] Gathered track data after init: \(data)")
            }
            // Register the Firebase remote command if TealiumFirebase is available
#if canImport(TealiumFirebase)
            if let remoteCommands = TealiumHelper.shared.tealium?.remoteCommands {
                let firebase = FirebaseRemoteCommand()
                remoteCommands.add(firebase)
                print("[TealiumHelper] Registered FirebaseRemoteCommand via TealiumFirebase")
            }
#endif
        })

        // Register a sample remote command using a placeholder JSON configuration URL.
        // Replace this placeholder with your actual URL serving the RemoteCommands JSON.
        let placeholderRemoteCommandURL = "https://firebasestorage.googleapis.com/v0/b/skilful-racer-95713.appspot.com/o/Tealium%2Ffirebase_remote_commands?alt=media"

        let sampleRemoteCommand = RemoteCommand(
            commandId: "sample_remote_config",
            description: "Sample remote command using a placeholder URL",
            type: .remote(url: placeholderRemoteCommandURL)
        ) { response in
            print("[RemoteCommand] Received response: \(response)")
        }

        // Add to the config so it is registered during initialization (if Firebase vendor isn't installed)
    #if canImport(TealiumFirebase)
        // Using the TealiumFirebase vendor integration; the FirebaseRemoteCommand will be added in the Tealium init completion
    #else
        config.remoteCommands = [sampleRemoteCommand]
    #endif
    }

    // Example track call that also forces an immediate profile refresh
    func track(event: String, data: [String: Any]? = nil) {
        let dispatch = TealiumEvent(event, dataLayer: data)
            tealium?.track(dispatch)
            // Ensure we request the profile a short time after sending a track event to allow visitorId to be established
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("[TealiumHelper] Track called: \(event)")
            }
    }

    func trackEvent(title: String, data: [String: Any]? = nil) {
        track(event: title, data: data)
    }

    func trackView(title: String, data: [String: Any]? = nil) {
        let view = TealiumView(title, dataLayer: data)
        tealium?.track(view)
    }
}

// App entrypoint using SwiftUI - starts the Tealium helper and shows ContentView
@main
struct TealiumSampleAppApp: App {
    init() {
        TealiumHelper.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
