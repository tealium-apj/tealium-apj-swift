import SwiftUI
import TealiumSwift

// Global Tealium instance
var tealiumInstance: Tealium?

// Simple file logger
func logToFile(_ message: String) {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let logMessage = "[\(timestamp)] \(message)\n"
    
    let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let logFile = docDir.appendingPathComponent("tealium_debug.log")
    
    if FileManager.default.fileExists(atPath: logFile.path) {
        if let handle = try? FileHandle(forWritingTo: logFile) {
            handle.seekToEndOfFile()
            handle.write(logMessage.data(using: .utf8) ?? Data())
            handle.closeFile()
        }
    } else {
        try? logMessage.write(to: logFile, atomically: true, encoding: .utf8)
    }
}

// Visitor Service delegate implementation (must be retained)
class VisitorServiceHandler: NSObject, VisitorServiceDelegate {
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        logToFile("[VisitorService] ✓ Profile updated!")
            logToFile("[VisitorService] Full profile received with attributes")
            if let audiences = visitorProfile.audiences {
                logToFile("[VisitorService] ✓ Audiences: \(audiences)")
            } else {
                logToFile("[VisitorService] Note: No audiences in profile")
        }
            if let badges = visitorProfile.badges {
                logToFile("[VisitorService] ✓ Badges: \(badges)")
            } else {
                logToFile("[VisitorService] Note: No badges in profile")
            }
            if let strings = visitorProfile.strings {
                logToFile("[VisitorService] String attributes: \(strings.keys.joined(separator: ", "))")
        }
    }
}

// Retain the delegate for the lifetime of the app
let visitorServiceHandler = VisitorServiceHandler()

@main
struct TealiumSampleAppApp: App {
    init() {
        logToFile("[Tealium] Initializing...")
        let config = TealiumConfig(
            account: "senda-ryunosuke-senda",
            profile: "mobile-test",
            environment: "prod"
        )

        // Enable verbose logging to see what Tealium is doing
        config.logLevel = .debug

        // Enable desired collectors and dispatchers via config properties
        config.collectors = [Collectors.AppData, Collectors.VisitorService, Collectors.Connectivity]
        config.dispatchers = [Dispatchers.Collect]

        // Register the retained visitor service delegate so the Visitor Service will fetch profiles
        config.visitorServiceDelegate = visitorServiceHandler
        
        // Set explicit refresh to trigger immediately and then periodically
        config.visitorServiceRefresh = .every(5, .seconds)

        // Initialize Tealium and request visitor profile in the init completion (per docs)
        tealiumInstance = Tealium(config: config) { _ in
            // Optional: send a lightweight track to ensure a visitor ID exists
            if let t = tealiumInstance {
                let initEvent = TealiumEvent("app_init", dataLayer: ["source": "auto_init"])
                t.track(initEvent)
                logToFile("[Tealium] Sent initial track event to establish visitor ID")
            }

            logToFile("[Tealium] ✓ Initialized with Visitor Service enabled (refresh: every 5 minutes)")

            // Request visitor profile immediately once Tealium is initialized
            logToFile("[Tealium] Requesting visitor profile (init completion)...")
            if let vs = tealiumInstance?.visitorService {
                logToFile("[Tealium] Visitor Service exists, requesting profile...")
                vs.requestVisitorProfile()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let cached = vs.cachedProfile {
                        logToFile("[Tealium] ✓ Cached profile found")
                        logToFile("[Tealium] Profile has audiences: \(cached.audiences != nil)")
                    } else {
                        logToFile("[Tealium] Note: No cached profile yet")
                    }
                }
            } else {
                logToFile("[Tealium] ERROR: Visitor Service is nil in completion handler!")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
