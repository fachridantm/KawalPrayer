import XCTest
import MapKit
@testable import KawalPrayer

final class LocationHelperTests: XCTestCase {

    func testCityAndDistrictFormatting() {
        // Both city and district present
        let result1 = LocationHelper.formatCityAndDistrict(city: "Central Jakarta", district: "Gambir")
        XCTAssertEqual(result1, "Central Jakarta, Gambir")

        let result2 = LocationHelper.formatCityAndDistrict(city: "Bandung", district: "Coblong")
        XCTAssertEqual(result2, "Bandung, Coblong")

        // Identical city and district
        let result3 = LocationHelper.formatCityAndDistrict(city: "Singapore", district: "Singapore")
        XCTAssertEqual(result3, "Singapore")

        // Only city present
        let result4 = LocationHelper.formatCityAndDistrict(city: "Jakarta", district: nil)
        XCTAssertEqual(result4, "Jakarta")

        let result5 = LocationHelper.formatCityAndDistrict(city: "Surabaya", district: "")
        XCTAssertEqual(result5, "Surabaya")

        // Only district present
        let result6 = LocationHelper.formatCityAndDistrict(city: nil, district: "Gambir")
        XCTAssertEqual(result6, "Gambir")

        // Neither present
        let result7 = LocationHelper.formatCityAndDistrict(city: nil, district: nil)
        XCTAssertEqual(result7, "Central Jakarta, Gambir")
    }

    func testPlacemarkFormatting() {
        let dict: [String: Any] = [
            "City": "Central Jakarta",
            "SubLocality": "Gambir"
        ]
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272),
            addressDictionary: dict
        )
        let formatted = LocationHelper.formatCityAndDistrict(from: placemark)
        XCTAssertEqual(formatted, "Central Jakarta, Gambir")
    }

    func testDefaultLocationModel() {
        let def = LocationModel.defaultLocation
        XCTAssertEqual(def.cityName, "Central Jakarta, Gambir")
        XCTAssertEqual(def.latitude, -6.1754, accuracy: 0.001)
        XCTAssertEqual(def.longitude, 106.8272, accuracy: 0.001)
        XCTAssertEqual(def.timezone, 7.0)
    }

    func testLocationModelCodable() {
        let original = LocationModel(
            latitude: -6.1754,
            longitude: 106.8272,
            cityName: "Central Jakarta, Gambir",
            timezone: 7.0
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        guard let data = try? encoder.encode(original),
              let decoded = try? decoder.decode(LocationModel.self, from: data) else {
            XCTFail("Failed to encode/decode LocationModel")
            return
        }

        XCTAssertEqual(decoded, original)
        XCTAssertEqual(decoded.cityName, "Central Jakarta, Gambir")
    }
}
