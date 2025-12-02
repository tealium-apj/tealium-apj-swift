import SwiftUI

@main
struct TealiumSampleAppApp: App {

    init() {
        TealiumHelper.shared.start()
        print("[App] TealiumHelper.start() called")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}