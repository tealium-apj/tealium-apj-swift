import SwiftUI

@main
struct TealiumSampleAppApp: App {
    @StateObject private var tealiumManager = TealiumManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tealiumManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var tealiumManager: TealiumManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("IDFA (device_advertising_id)")
                        .font(.headline)
                    Text(tealiumManager.idfa)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(3)

                    Text("Advertising Enabled (device_advertising_enabled)")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(tealiumManager.advertisingEnabled)
                        .font(.system(.body, design: .monospaced))

                    Text("ATT Status (device_tracking_authorization)")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(tealiumManager.trackingAuthorization)
                        .font(.system(.body, design: .monospaced))
                }

                Spacer()

                Button(action: {
                    print("Refresh button tapped.")
                    tealiumManager.refreshValues()
                }) {
                    Text("Refresh Values")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    print("Sending test event via Tealium.")
                    tealiumManager.trackTestEvent()
                }) {
                    Text("Send Test Event (Optional)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

            }
            .padding()
            .navigationTitle("Tealium IDFA Test")
        }
        .onAppear {
            print("ContentView appeared – requesting initial refresh.")
            tealiumManager.refreshValues()
        }
    }
}