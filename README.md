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
