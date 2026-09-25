import XCTest
@testable import KawalPrayer

final class QiblaCalculatorTests: XCTestCase {

    func testJakartaQiblaDirection() {
        // Jakarta coordinates: -6.2088, 106.8456
        // Expected Qibla bearing from Jakarta is approximately 295° (West-Northwest / BLB / WNW)
        let qibla = QiblaCalculator.calculate(latitude: -6.2088, longitude: 106.8456)
        XCTAssertEqual(qibla.degrees, 295.0, accuracy: 2.0, "Qibla Jakarta harus ~295°")
        XCTAssertEqual(qibla.cardinalDirection(for: .id), "BLB", "Arah Jakarta dalam Bahasa Indonesia adalah Barat Laut Barat (BLB)")
        XCTAssertEqual(qibla.cardinalDirection(for: .en), "WNW", "Arah Jakarta dalam Bahasa Inggris adalah West-Northwest (WNW)")
    }

    func testTokyoQiblaDirection() {
        // Tokyo coordinates: 35.6762, 139.6503
        // Expected Qibla bearing is ~293°
        let qibla = QiblaCalculator.calculate(latitude: 35.6762, longitude: 139.6503)
        XCTAssertEqual(qibla.degrees, 293.0, accuracy: 3.0)
    }
}
