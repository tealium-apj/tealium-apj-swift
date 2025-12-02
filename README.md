TealiumSampleApp


# TealiumSampleApp

Minimal SwiftUI app skeleton fully integrated with the Tealium SDK via CocoaPods.

## How to Build and Run

### 1. Clone the repository

```bash
git clone <repo-url>
cd TealiumSampleApp
```

### 2. Install dependencies (CocoaPods)

If you don't have CocoaPods installed:

```bash
sudo gem install cocoapods
```

Then install pods:

```bash
pod install
```

### 3. Build and Run (Xcode GUI)

```bash
open TealiumSampleApp.xcworkspace
```
In Xcode:
- Select an iOS simulator (e.g., iPhone 16)
- Press **Cmd+R** to build and run

### 4. Build and Run (Command Line)

First, build the app:

```bash
xcodebuild -workspace TealiumSampleApp.xcworkspace -scheme TealiumSampleApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Then, launch the simulator and install/run the app:

```bash
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/TealiumSampleApp-*/Build/Products/Debug-iphonesimulator/TealiumSampleApp.app
xcrun simctl launch booted com.example.tealium.sampleapp
```

## Configuration
To customize Tealium configuration (account, profile, environment), edit `TealiumSampleAppApp.swift` and update the `TealiumConfig` values:

```swift
let config = TealiumConfig(
    account: "tealiummobile",
    profile: "demo",
    environment: "dev"
)
```
Replace with your Tealium account details as needed.

### Remote Commands: Using the RemoteCommands Dispatcher
You can enable the RemoteCommands dispatcher and register JSON-based RemoteCommands that the SDK will fetch from a remote URL.

In `TealiumSampleAppApp.swift`, a sample RemoteCommand has been included using a placeholder URL:

```swift
let placeholderRemoteCommandURL = "https://example.com/remote-command-configs/sample.json"
let sampleRemoteCommand = RemoteCommand(
    commandId: "sample_remote_config",
    description: "Sample remote command using a placeholder URL",
    type: .remote(url: placeholderRemoteCommandURL)
) { response in
    print("[RemoteCommand] Received response: \(response)")
}
config.remoteCommands = [sampleRemoteCommand]
 config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]
```

Replace `placeholderRemoteCommandURL` with the URL that points to your JSON Remote Command configuration.
If you want to use both RemoteCommands and Collect, you can add both dispatchers:

```swift
 config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]
```

Use the `config.remoteCommandConfigRefresh` to control how frequently the SDK fetches remote command JSON files.

#### Example remote command JSON
Here's a minimal example of a remote command JSON that can be hosted at the placeholder URL. Update names, mappings, and commands to match your deployment:

```json
{
    "config": {
        "method": "GET",
        "url": "https://api.example.com/endpoint"
    },
    "mappings": {
        "custom_key": "api_key"
    },
    "commands": {
        "success": "js_to_execute_on_success"
    }
}
```

For a full JSON schema and advanced mappings, refer to the Tealium Remote Commands docs.

#### Sample swift usage (conditional Firebase remote command)
This example shows how to configure Tag Management + RemoteCommands and register a Firebase remote command only when the `TealiumFirebase` module is available:

```swift
import TealiumSwift
#if canImport(TealiumFirebase)
import TealiumFirebase
#endif

let config = TealiumConfig(account: "ACCOUNT", profile: "PROFILE", environment: "dev")
 config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]
config.remoteAPIEnabled = true

tealium = Tealium(config: config) { _ in
    #if canImport(TealiumFirebase)
    if let rc = tealium?.remoteCommands {
        let firebaseCommand = FirebaseRemoteCommand()
        rc.add(firebaseCommand)
    }
    #endif
}
```

### Tag Management & Firebase Remote Commands
If you're using client-side tag management (iQ) or vendor SDK integrations such as Firebase, enable `TagManagement` and `RemoteCommands` for the SDK to fetch remote JSON configs and run commands.

In your `Podfile`, add or uncomment TagManagement. If you plan to use `FirebaseRemoteCommand`, add the Tealium Firebase integration if available (example – adapt to your version):

```ruby
pod 'tealium-swift/TagManagement'
# Optional vendor integrations:
# pod 'tealium-swift/Firebase' # (if supported; check Tealium docs for correct pod name)
```

The sample app now avoids using the `VisitorService` collector by default — if you need the Visitor Service, re-enable it in the `Podfile` and add back the `Collectors.VisitorService` to `config.collectors`.

## Files
- `README.md` — this file
- `Podfile` — CocoaPods dependency configuration
- `Podfile.lock` — locked pod versions
- `Info.plist` — iOS app configuration
- `Sources/TealiumSampleApp/` — Swift source files (app entry, UI)
- `TealiumSampleApp.xcodeproj/` — Xcode project structure
- `TealiumSampleApp.xcworkspace/` — Xcode workspace (use this to open in Xcode, not the .xcodeproj)
- `Pods/` — CocoaPods-managed dependencies

## Notes
- Always open `.xcworkspace` (not `.xcodeproj`) in Xcode after running `pod install`.
- The "Track Event" button demonstrates sending events using Tealium's API.
 - The "Track Event" button demonstrates sending events using Tealium's API.
 - The "Trigger Remote Commands" button triggers JSON-based Remote Commands configured in your remote configs or local JSON (if registered).
