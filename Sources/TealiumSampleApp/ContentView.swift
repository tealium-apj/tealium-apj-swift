import SwiftUI
import TealiumSwift

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tealium Sample App")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    // Track a simple event using Tealium
                    let event = TealiumEvent("button_pressed", dataLayer: ["button": "track_event_button"])
                    tealiumInstance?.track(event)
                    logToFile("[ContentView] Event tracked: button_pressed")
                }) {
                    Text("Track Event")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    logToFile("[ContentView] Requesting visitor profile...")
                    if let visitorService = tealiumInstance?.visitorService {
                        visitorService.requestVisitorProfile()
                        logToFile("[ContentView] ✓ Visitor profile request sent")
                    } else {
                        logToFile("[ContentView] ✗ Visitor Service is nil!")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
