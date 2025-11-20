# Tealium Swift VisitorService Integration Guide

## Overview

The VisitorService module implements the [Data Layer Enrichment](https://docs.tealium.com/server-side/attributes/data-layer-enrichment/enable/) feature of the Tealium Customer Data Hub. It retrieves visitor profiles from the Tealium AudienceStream platform.

**Important**: Usage of this module is recommended **only if you are licensed for Tealium AudienceStream**. If you are not licensed for AudienceStream, no visitor profile will be returned.

---

## Prerequisites & Requirements

### 1. Account/Profile Configuration
- **AudienceStream License**: Your Tealium account must have AudienceStream enabled
- **Profile Selection**: The VisitorService will fetch profiles from the AudienceStream profile specified in your Tealium configuration
- **Data Layer Enrichment**: Must be enabled in your Tealium iQ publish settings:
  1. Admin menu → Configure Publish Settings
  2. General Publishing tab → Implementation section
  3. Select the appropriate **Data Layer Enrichment Profile**
  4. Apply and save changes to Prod environment

### 2. Module Installation
```ruby
# CocoaPods
pod 'tealium-swift/Core'
pod 'tealium-swift/Collect'        # or 'tealium-swift/TagManagement'
pod 'tealium-swift/VisitorService'
```

### 3. Required Imports
```swift
import TealiumCore
import TealiumCollect          // or TealiumTagManagement
import TealiumVisitorService
```

---

## Configuration

### Basic Setup

```swift
let config = TealiumConfig(
    account: "ACCOUNT",
    profile: "PROFILE",
    environment: "ENVIRONMENT",
    datasource: "DATASOURCE"
)

// Enable VisitorService collector
config.collectors = [Collectors.VisitorService]

// Set delegate to receive profile updates
config.visitorServiceDelegate = self

// Configure refresh interval (default: 5 minutes)
config.visitorServiceRefresh = .every(5, .minutes)
```

### Configuration Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `visitorServiceDelegate` | VisitorServiceDelegate | Implements `didUpdate()` callback | nil |
| `visitorServiceRefresh` | RefreshInterval | Frequency of profile retrieval | `.every(5, .minutes)` |
| `visitorServiceOverrideProfile` | String | Override AudienceStream profile name | Config profile value |
| `visitorServiceOverrideURL` | String | Override base URL for visitor profile endpoint | Tealium standard URL |

### Refresh Interval Options

```swift
// Fetch every X seconds/minutes/hours
config.visitorServiceRefresh = .every(3, .seconds)
config.visitorServiceRefresh = .every(10, .minutes)
config.visitorServiceRefresh = .every(1, .hours)

// OR fetch on every track call
config.visitorServiceRefresh = .every(0, .seconds)
```

---

## Implementation

### Step 1: Implement VisitorServiceDelegate

```swift
extension YourClass: VisitorServiceDelegate {
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        // This method is called when the visitor profile is updated
        print("Profile updated!")
        print("Audiences: \(visitorProfile.audiences ?? [:])")
    }
}
```

### Step 2: Set Delegate in Config

```swift
class TealiumHelper {
    let config = TealiumConfig(...)
    
    init() {
        config.visitorServiceDelegate = self  // Must be set before init
        self.tealium = Tealium(config: config)
    }
}

extension TealiumHelper: VisitorServiceDelegate {
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        // Handle profile updates
    }
}
```

### Step 3: Trigger Manual Profile Fetch

```swift
// Automatic: Fetched at configured interval or with each track call (if refresh = 0)
// Manual: Call this anytime to fetch immediately
tealium?.visitorService?.requestVisitorProfile()
```

---

## Accessing Visitor Profile Data

### Profile Data Types

The visitor profile contains multiple attribute types:

| Attribute | Type | Example |
|-----------|------|---------|
| `strings` | `[String: String]` | `["5699": "Toy Tea Set"]` |
| `numbers` | `[String: Double]` | `["1399": 4.82125]` |
| `booleans` | `[String: Bool]` | `["4868": true]` |
| `dates` | `[String: Int]` | `["25": 1567120112000]` (timestamp) |
| `audiences` | `[String: String]` | `["tealiummobile_demo_103": "iOS Users"]` |
| `badges` | `[String: Bool]` | `["2815": true]` |
| `arraysOfStrings` | `[String: [String]]` | `["3390": ["Bootleg Jeans", "Dresses"]]` |
| `arraysOfNumbers` | `[String: [Double]]` | `["57": [4.82125, 16.8]]` |
| `arraysOfBooleans` | `[String: [Bool]]` | `["5129": [true, false, true]]` |
| `setsOfStrings` | `[String: Set<String>]` | `["2300": ["Luxury Couch 1", "Luxury Couch 2"]]` |
| `tallies` | `[String: [String: Double]]` | `["1399": ["girls": 3.0, "womens": 1.0]]` |
| `currentVisit` | `TealiumCurrentVisitProfile` | Visit-scoped attributes |

### Example: Accessing Visitor Data

```swift
func didUpdate(visitorProfile: TealiumVisitorProfile) {
    // Access string attribute by ID
    if let category = visitorProfile.strings?["5699"] {
        print("User category: \(category)")
    }
    
    // Check audience membership
    if let audiences = visitorProfile.audiences {
        if audiences["tealiummobile_demo_107"] != nil {
            print("User is in Cart Abandoners audience")
        }
    }
    
    // Access numeric attribute
    if let score = visitorProfile.numbers?["1399"] {
        if score > 3.0 {
            print("High value customer: \(score)")
        }
    }
    
    // Check badge assignment
    if let badgeAssigned = visitorProfile.badges?["2815"] {
        print("Badge assigned: \(badgeAssigned)")
    }
    
    // Access current visit data
    if let currentVisit = visitorProfile.currentVisit,
       let visitString = currentVisit.strings?["34"] {
        print("Current visit data: \(visitString)")
    }
    
    // Access tally (category counts)
    if let tally = visitorProfile.tallies?["1399"],
       let categoryCount = tally["red shirts"] {
        print("Red shirts purchased: \(categoryCount)")
    }
}
```

### Getting Cached Profile (Offline Access)

```swift
// Returns the most recently-fetched profile from persistent storage
// Does NOT trigger a new network request
if let cachedProfile = tealium?.visitorService?.cachedProfile {
    let audiences = cachedProfile.audiences
    // Use cached profile while offline
}
```

### Encoding Profile to JSON (Logging/Debugging)

```swift
if let json = try? JSONEncoder().encode(visitorProfile),
   let jsonString = String(data: json, encoding: .utf8) {
    print("Full profile JSON: \(jsonString)")
}
```

---

## API Endpoints

The VisitorService makes HTTP requests to fetch visitor profiles:

### Default Endpoint Format
```
https://visitor-service.tealiumapis.com/v1/{account}/{profile}/{visitor_id}
```

**Where:**
- `{account}`: Your Tealium account name
- `{profile}`: Your AudienceStream profile name
- `{visitor_id}`: The Tealium visitor ID (from `tealium_vid` data layer variable)

### Custom Endpoint Override

```swift
config.visitorServiceOverrideURL = "https://custom-endpoint.yourdomain.com/"
// The account/profile/visitor_id are automatically appended
```

---

## Troubleshooting

### Profiles Not Being Returned - Checklist

1. **Verify AudienceStream License**
   - Check account has AudienceStream enabled
   - Contact Tealium support if license is missing

2. **Enable Data Layer Enrichment in Tealium iQ**
   - Admin → Configure Publish Settings
   - General Publishing → Data Layer Enrichment Profile
   - Must be set to the correct profile
   - Publish to Prod environment

3. **Verify Collector is Enabled**
   ```swift
   config.collectors = [Collectors.VisitorService]
   ```

4. **Set Delegate Before Initialization**
   ```swift
   config.visitorServiceDelegate = self  // MUST be set before Tealium init
   ```

5. **Check Refresh Interval**
   ```swift
   // Default is 5 minutes - didUpdate won't fire more frequently
   // Set to 0 to fetch on every track call:
   config.visitorServiceRefresh = .every(0, .seconds)
   ```

6. **Verify Visitor ID is Available**
   - Requires at least one track call to establish visitor ID
   - Check `tealium_vid` in data layer

7. **Check Network Connectivity**
   - Verify device has internet connection
   - Profiles cannot be fetched offline (use `cachedProfile` for offline data)

### Debugging: Enable Verbose Logging

```swift
config.logLevel = .debug  // Enables detailed logging from all modules

// In didUpdate delegate, log the full profile:
if let json = try? JSONEncoder().encode(visitorProfile),
   let string = String(data: json, encoding: .utf8) {
    print("Visitor Profile: \(string)")
}
```

### Common Issues

| Issue | Solution |
|-------|----------|
| `didUpdate()` never fires | 1. Check AudienceStream license<br>2. Verify Data Layer Enrichment enabled in iQ<br>3. Set delegate before Tealium init<br>4. Ensure at least one track call sent |
| Profile is empty | 1. Verify profile has attributes configured<br>2. Check visitor qualifies for any audiences<br>3. Allow time for profile to populate in AudienceStream |
| Endpoint 404 errors | 1. Verify account/profile names are correct<br>2. Check visitor ID is set (send track call first)<br>3. Verify override URL if using custom endpoint |
| Stale cached profile | Use `requestVisitorProfile()` to force refresh ignoring interval |

---

## Example: Complete Implementation

```swift
import UIKit
import TealiumSwift

class TealiumHelper {
    static let shared = TealiumHelper()
    var tealium: Tealium?
    
    private init() {
        let config = TealiumConfig(
            account: "tealiummobile",
            profile: "demo",
            environment: "dev",
            datasource: "test123"
        )
        
        // Configure VisitorService
        config.visitorServiceDelegate = self
        config.visitorServiceRefresh = .every(5, .minutes)
        config.collectors = [Collectors.VisitorService, Collectors.Lifecycle]
        config.dispatchers = [Dispatchers.Collect]
        config.logLevel = .debug
        
        tealium = Tealium(config: config) { [weak self] _ in
            self?.tealium?.track(TealiumEvent("tealium_initialized"))
        }
    }
    
    func trackEvent(name: String, data: [String: Any]? = nil) {
        let event = TealiumEvent(name, dataLayer: data)
        tealium?.track(event)
    }
    
    func requestProfileUpdate() {
        tealium?.visitorService?.requestVisitorProfile()
    }
}

extension TealiumHelper: VisitorServiceDelegate {
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        print("=== VISITOR PROFILE UPDATED ===")
        
        // Log full profile
        if let json = try? JSONEncoder().encode(visitorProfile),
           let string = String(data: json, encoding: .utf8) {
            print("Profile JSON: \(string)")
        }
        
        // Access specific attributes
        if let audiences = visitorProfile.audiences {
            print("Audiences: \(audiences)")
        }
        
        if let badges = visitorProfile.badges {
            print("Badges: \(badges)")
        }
        
        // Use profile for personalization
        if let category = visitorProfile.strings?["5699"] {
            print("Product category preference: \(category)")
        }
        
        print("================================")
    }
}
```

---

## Release Notes

**Version 2.0.0** (Latest)
- Updated TealiumVisitorProfile for better performance
- Removed multicast delegate (single delegate only)
- Removed completion from cached profile method
- Enhanced delegate method signature
- Added more refresh interval options

---

## Additional Resources

- **Official Documentation**: https://docs.tealium.com/platforms/ios-swift/module-list/visitor-service/
- **Sample App**: https://github.com/Tealium/tealium-swift/tree/main/samples/VisitorServiceDemo
- **Data Layer Info**: https://docs.tealium.com/platforms/ios-swift/data-layer/
- **AudienceStream Docs**: https://docs.tealium.com/server-side/attributes/data-layer-enrichment/
