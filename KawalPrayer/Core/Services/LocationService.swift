import Foundation
import CoreLocation
import Observation

@Observable
final class LocationService: NSObject {

    var currentLocation: CLLocation?
    var cityName: String = ""
    var authStatus: CLAuthorizationStatus = .notDetermined
    var isRefreshing: Bool = false
    var errorMessage: String?

    var onLocationUpdated: ((CLLocation, String) -> Void)?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 3000 // Update when user moves 3 km or more
        authStatus = manager.authorizationStatus
    }

    // MARK: - Permissions & Monitoring

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startMonitoring() {
        requestPermission()
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            manager.startMonitoringSignificantLocationChanges()
        }
        manager.startUpdatingLocation()
    }

    func stopMonitoring() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            manager.stopMonitoringSignificantLocationChanges()
        }
        manager.stopUpdatingLocation()
    }

    /// Trigger manual one-time refresh with progress state
    func refreshLocation() {
        isRefreshing = true
        errorMessage = nil
        manager.requestLocation()
    }

    // MARK: - Reverse Geocoding

    private func reverseGeocode(_ location: CLLocation) {
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            self.isRefreshing = false
            if let error {
                self.errorMessage = error.localizedDescription
                return
            }
            guard let place = placemarks?.first else { return }
            let formattedLocation = LocationHelper.formatCityAndDistrict(from: place)
            self.cityName = formattedLocation
            self.onLocationUpdated?(location, formattedLocation)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: @preconcurrency CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc
        reverseGeocode(loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRefreshing = false
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        #if os(macOS)
        if authStatus == .authorizedAlways || authStatus == .authorized {
            startMonitoring()
            refreshLocation()
        }
        #endif
    }
}
