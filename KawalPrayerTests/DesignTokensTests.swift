import XCTest
import SwiftUI
@testable import KawalPrayer

final class DesignTokensTests: XCTestCase {

    func testDimensTokens() {
        XCTAssertEqual(DimensToken.SIZE_0, 0.0)
        XCTAssertEqual(DimensToken.SIZE_8, 8.0)
        XCTAssertEqual(DimensToken.SIZE_16, 16.0)
        XCTAssertEqual(DimensToken.SIZE_24, 24.0)
        XCTAssertEqual(DimensToken.SIZE_32, 32.0)
        XCTAssertEqual(DimensToken.SIZE_80, 80.0)
    }

    func testFloatTokens() {
        XCTAssertEqual(FloatToken.PERCENT_0, 0.0)
        XCTAssertEqual(FloatToken.PERCENT_50, 0.50)
        XCTAssertEqual(FloatToken.PERCENT_100, 1.00)
    }

    func testOXSpacingScale() {
        XCTAssertEqual(OX.Spacing.None, DimensToken.SIZE_0)
        XCTAssertEqual(OX.Spacing.XS, DimensToken.SIZE_4)
        XCTAssertEqual(OX.Spacing.S, DimensToken.SIZE_8)
        XCTAssertEqual(OX.Spacing.M, DimensToken.SIZE_12)
        XCTAssertEqual(OX.Spacing.L, DimensToken.SIZE_16)
        XCTAssertEqual(OX.Spacing.XL, DimensToken.SIZE_20)
    }

    func testOXRadiusScale() {
        XCTAssertEqual(OX.Radius.XS, DimensToken.SIZE_4)
        XCTAssertEqual(OX.Radius.S, DimensToken.SIZE_8)
        XCTAssertEqual(OX.Radius.M, DimensToken.SIZE_12)
        XCTAssertEqual(OX.Radius.L, DimensToken.SIZE_16)
        XCTAssertEqual(OX.Radius.XL, DimensToken.SIZE_20)
        XCTAssertEqual(OX.Radius.FULL, 999.0)
    }

    func testOXBorderWidth() {
        XCTAssertEqual(OX.Border.WIDTH_0_5, 0.5)
        XCTAssertEqual(OX.Border.WIDTH_1, 1.0)
        XCTAssertEqual(OX.Border.WIDTH_1_5, 1.5)
        XCTAssertEqual(OX.Border.WIDTH_2, 2.0)
    }

    func testOutivoxColors() {
        XCTAssertNotNil(ColorToken.Blue)
        XCTAssertNotNil(ColorToken.Green)
        XCTAssertNotNil(ColorToken.Yellow)
        XCTAssertNotNil(ColorToken.Red)
        XCTAssertNotNil(ColorToken.LightGrey10)
        XCTAssertNotNil(ColorToken.DarkGrey10)
    }

    func testOXSemanticColors() {
        XCTAssertEqual(OX.Color.primary, ColorToken.Green)
        XCTAssertEqual(OX.Color.secondary, ColorToken.Blue)
        XCTAssertEqual(OX.Color.prayerActive(for: .light), ColorToken.Green)
        XCTAssertEqual(OX.Color.prayerActive(for: .dark), ColorToken.Green)
        XCTAssertEqual(OX.Color.nextPrayer(for: .light), ColorToken.Blue)
    }
}
