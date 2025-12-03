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
            environment: "prod"
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

        // Optional: more verbose logging while testing
        config.logLevel = .debug

        // Initialize Tealium using the designated initializer (no static .initialize)
        tealium = Tealium(config: config) { [weak self] _ in
            print("Tealium initialized successfully.")
            self?.requestATTAndRefresh()
        }
    }

    // MARK: - ATT Request

    private func requestATTAndRefresh() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                print("ATT authorization status: \(status.rawValue)")
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

    /// Manually refresh values from the Tealium data layer
    func refreshValues() {
        guard let tealium = tealium else {
            print("Tealium not initialized yet.")
            return
        }

        let data = tealium.dataLayer.all

        // device_advertising_id (IDFA)
        let idfaValue = data["device_advertising_id"] as? String ?? "nil"

        // device_advertising_enabled (Bool)
        let enabledBool = data["device_advertising_enabled"] as? Bool
        let enabledValue = enabledBool.map { String($0) } ?? "nil"

        // device_tracking_authorization (String, e.g. "authorized", "denied")
        let authValue = data["device_tracking_authorization"] as? String ?? "nil"

        // Update UI properties
        DispatchQueue.main.async {
            self.idfa = idfaValue
            self.advertisingEnabled = enabledValue
            self.trackingAuthorization = authValue
        }

        // Console logs for debugging
        print("----- Tealium Attribution Values -----")
        print("device_advertising_id         = \(idfaValue)")
        print("device_advertising_enabled    = \(enabledValue)")
        print("device_tracking_authorization = \(authValue)")
        print("--------------------------------------")
    }

    /// Optional: Send a simple test event through Tealium (not required for IDFA)
    func trackTestEvent() {
        let event = TealiumEvent("test_event", dataLayer: [
            "example_key": "example_value"
        ])
        tealium?.track(event)
    }
}