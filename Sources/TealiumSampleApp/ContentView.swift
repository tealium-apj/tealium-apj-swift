import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tealium Sample App")
                    .font(.largeTitle)
                    .padding()

                Text(TealiumHelper.shared.debugConfigSummary)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)

                Button(action: {
                    TealiumHelper.shared.track(
                        event: "button_pressed",
                        data: ["button": "track_event_button"]
                    )
                    print("[ContentView] Event tracked: button_pressed")

                    if let vid = TealiumHelper.shared.tealium?.visitorId {
                        print("[ContentView] Current visitorId: \(vid)")
                    } else {
                        print("[ContentView] visitorId is nil (Tealium not yet fully initialized?)")
                    }
                }) {
                    Text("Track Event")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    print("[ContentView] Triggering Firebase RemoteCommands JSON commands (if any)")

                    let data: [String: Any] = [
                        "payload": [
                            "sdk_event": "triggered_from_app_button"
                        ]
                    ]

                    TealiumHelper.shared.tealium?
                        .remoteCommands?
                        .trigger(command: .JSON, with: data, completion: nil)
                }) {
                    Text("Trigger Remote Commands")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}