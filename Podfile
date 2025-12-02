# Podfile
platform :ios, '11.0'  # adjust to your app's minimum iOS version
target 'TealiumSampleApp' do
  use_frameworks!

  # Core + common collectors/dispatchers
  pod 'tealium-swift/Core'
  pod 'tealium-swift/Lifecycle'

  # Choose ONE primary dispatcher path:

  # Server-side (EventStream/AudienceStream, etc.)
  pod 'tealium-swift/Collect'          # sends to Tealium Customer Data Hub
  # pod 'tealium-swift/TagManagement'  # OR client-side via iQ (uncomment to enable)

  # Add if you need Remote Commands (for vendor SDKs via iQ or JSON)
  pod 'tealium-swift/RemoteCommands'

  pod 'TealiumFirebase'                     # Firebase integration module

  # Optional modules (uncomment as needed)
  # VisitorService removed from sample - uncomment to re-enable
  # pod 'tealium-swift/VisitorService'  # fetch AudienceStream visitor profile info
  # pod 'tealium-swift/Attribution'     # iOS-only attribution/IDFA
  # pod 'tealium-swift/Location'        # location/geofencing
  # pod 'TealiumCrashModule'            # crash reporting (installs crash reporter dep)
end