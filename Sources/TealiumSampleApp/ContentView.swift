import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
