import SwiftUI
import TealiumSwift

final class TealiumHelper: NSObject {

    static let shared = TealiumHelper()

    private(set) var tealium: Tealium?

    func start() {
        let config = TealiumConfig(
            account: "success-ryunosuke-senda",
            profile: "mobile-test",
            environment: "prod",
        )

        // Collectors: include Device & Connectivity when customizing, plus VisitorService
        config.collectors = [
            Collectors.AppData,
            Collectors.Device,
            Collectors.Connectivity,
            Collectors.Lifecycle,
            Collectors.VisitorService
        ]

        // Choose one dispatcher path (server-side via Collect shown here)
        config.dispatchers = [Dispatchers.Collect]

        // (Optional) Adjust refresh cadence for profile fetches (default is every 5 minutes)
        config.visitorServiceRefresh = .every(15, .seconds)

        // Receive profile updates
        config.visitorServiceDelegate = self

        // Enable verbose SDK logging for debugging
        config.logLevel = .debug
        tealium = Tealium(config: config, enableCompletion: { _ in
            // Immediately request the latest profile on startup (optional)
            print("[TealiumHelper] Initialization completion: gathering track data and requesting visitor profile")
            TealiumHelper.shared.tealium?.gatherTrackData(retrieveCachedData: true) { data in
                print("[TealiumHelper] Gathered track data after init: \(data)")
            }
            // Request profile
            TealiumHelper.shared.tealium?.visitorService?.requestVisitorProfile()
            // Also check cached profile shortly after
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let cached = TealiumHelper.shared.tealium?.visitorService?.cachedProfile {
                    print("[TealiumHelper] Cached profile present after init: \(cached)")
                } else {
                    print("[TealiumHelper] No cached profile found after init completion")
                }
            }
        })
    }

    // Example track call that also forces an immediate profile refresh
    func track(event: String, data: [String: Any]? = nil) {
        let dispatch = TealiumEvent(event, dataLayer: data)
            tealium?.track(dispatch)
            // Ensure we request the profile a short time after sending a track event to allow visitorId to be established
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                TealiumHelper.shared.tealium?.visitorService?.requestVisitorProfile()
                print("[TealiumHelper] Forced visitor profile request after track")
            }
    }

    // Access the last cached profile anytime (e.g., to pre-populate UI)
    var cachedVisitorProfile: TealiumVisitorProfile? {
        tealium?.visitorService?.cachedProfile
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

// MARK: - Visitor Service Delegate

extension TealiumHelper: VisitorServiceDelegate {

    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        // Audiences membership by ID
        if let audiences = visitorProfile.audiences,
           audiences["account_profile_106"] != nil {
            print("Member of audience id 106")
        }

        // Badge presence by ID
        if let isVIP = visitorProfile.badges?["vip_customer"], isVIP {
            print("VIP badge assigned")
        }

        // Current visit example (audiences/badges are visitor-scope only)
        if let currentVisitString = visitorProfile.currentVisit?.strings?["34"] {
            print("Current visit string attribute 34: \(currentVisitString)")
        }
    }
}