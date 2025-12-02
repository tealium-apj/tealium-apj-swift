import SwiftUI
import TealiumSwift

struct ContentView: View {
    @State private var tagProfile: String = "(unknown)"
    @State private var publishSettingsProfile: String = "(unknown)"
    @State private var visitorServiceProfile: String = "(none)"
    @State private var visitorProfileSummary: String = "(none)"
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Display the currently configured Tealium profile and visitor profile state
                VStack(spacing: 4) {
                    Text("Config profile: \(tagProfile)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Publish settings profile: \(publishSettingsProfile)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Visitor Service profile: \(visitorServiceProfile)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Visitor profile: \(visitorProfileSummary)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("Tealium Sample App")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    TealiumHelper.shared.track(event: "button_pressed", data: ["button": "track_event_button"]) 
                    print("[ContentView] Event tracked: button_pressed")
                }) {
                    Text("Track Event")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    print("[ContentView] Requesting visitor profile...")
                    if let visitorService = TealiumHelper.shared.tealium?.visitorService {
                        visitorService.requestVisitorProfile()
                        print("[ContentView] ✓ Visitor profile request sent")
                    } else {
                        print("[ContentView] ✗ Visitor Service is nil!")
                    }
                }) {
                    Text("Request Visitor Profile")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
                .onAppear {
                // Read initial values from the Tealium helper
                if let config = TealiumHelper.shared.config {
                    // config.profile is non-optional
                    tagProfile = config.profile
                    publishSettingsProfile = config.publishSettingsProfile ?? config.profile
                    visitorServiceProfile = config.visitorServiceOverrideProfile ?? config.profile
                } else {
                    tagProfile = "(none)"
                    publishSettingsProfile = "(none)"
                    visitorServiceProfile = "(none)"
                }
                if let cached = TealiumHelper.shared.cachedVisitorProfile {
                    visitorProfileSummary = cached.audiences?.keys.joined(separator: ", ") ?? "(present)"
                } else {
                    visitorProfileSummary = "(none)"
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .tealiumVisitorProfileUpdated)) { notification in
                // Update UI when visitor profile updates arrive
                if let profile = notification.userInfo?["profile"] as? TealiumVisitorProfile {
                    visitorProfileSummary = profile.audiences?.keys.joined(separator: ", ") ?? "(present)"
                    print("[ContentView] Received updated visitor profile; audiences: \(visitorProfileSummary)")
                } else {
                    // Fallback to cached value
                    if let cached = TealiumHelper.shared.cachedVisitorProfile {
                        visitorProfileSummary = cached.audiences?.keys.joined(separator: ", ") ?? "(present)"
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
