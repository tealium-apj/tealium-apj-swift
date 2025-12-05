import Foundation
import Combine
import TealiumSwift
import AppTrackingTransparency
import AdSupport

final class TealiumManager: ObservableObject {

    // MARK: - Published properties for SwiftUI

    @Published var idfa: String = "N/A"
    @Published var advertisingEnabled: String = "N/A"
    @Published var trackingAuthorization: String = "N/A"

    // MARK: - Internal Tealium instance

    private var tealium: Tealium?

    // MARK: - Init

    init() {
        setupTealium()
    }

    // MARK: - Tealium Setup

    private func setupTealium() {
        // TODO: replace with your actual Tealium account/profile/env
        let config = TealiumConfig(
            account: "success-ryunosuke-senda",
            profile: "mobile-test",
            environment: "dev"
        )

        // Collectors: AppData, Device, Attribution
        config.collectors = [
            Collectors.AppData,
            Collectors.Device,
            Collectors.Attribution
        ]

        // Dispatcher: Collect (to send events to Tealium CDH)
        config.dispatchers = [
            Dispatchers.Collect
        ]

        config.logLevel = .debug

        tealium = Tealium(config: config) { [weak self] _ in
            print("Tealium initialized successfully.")
            self?.requestATTAndRefresh()
        }
    }

    // MARK: - ATT Request

    private func requestATTAndRefresh() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                print("ATT authorization status (raw): \(status.rawValue)")
                let statusDescription: String
                switch status {
                case .notDetermined: statusDescription = "notDetermined"
                case .restricted:    statusDescription = "restricted"
                case .denied:        statusDescription = "denied"
                case .authorized:    statusDescription = "authorized"
                @unknown default:    statusDescription = "unknown"
                }
                print("ATT authorization status: \(statusDescription)")

                DispatchQueue.main.async {
                    self?.refreshValues()
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.refreshValues()
            }
        }
    }

    // MARK: - Public API

    /// Manually refresh values from Tealium *and* log OS-level IDFA for comparison
    func refreshValues() {
        guard let tealium = tealium else {
            print("Tealium not initialized yet.")
            return
        }

        // Log the OS-level IDFA directly from AdSupport for comparison
        let systemIdfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("System IDFA from AdSupport = \(systemIdfa)")

        // Gather module-enriched track data (this is where Attribution writes its values)
        tealium.gatherTrackData { [weak self] data in
            guard let self = self else { return }

            let idfaValue = data["device_advertising_id"] as? String ?? "nil"
            let enabledBool = data["device_advertising_enabled"] as? Bool
            let enabledValue = enabledBool.map { String($0) } ?? "nil"
            let authValue = data["device_tracking_authorization"] as? String ?? "nil"

            DispatchQueue.main.async {
                self.idfa = idfaValue
                self.advertisingEnabled = enabledValue
                self.trackingAuthorization = authValue
            }

            print("----- Tealium Attribution Values (gatherTrackData) -----")
            print("device_advertising_id         = \(idfaValue)")
            print("device_advertising_enabled    = \(enabledValue)")
            print("device_tracking_authorization = \(authValue)")
            print("--------------------------------------------------------")
        }
    }

    /// Optional: Send a simple test event through Tealium (not required for IDFA)
    func trackTestEvent() {
        let event = TealiumEvent("test_event", dataLayer: [
            "example_key": "example_value"
        ])
        tealium?.track(event)
    }
}