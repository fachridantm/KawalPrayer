import Foundation

struct QiblaDirection: Equatable {
    let degrees: Double
    let cardinalDirection: String

    var formattedBearing: String {
        "\(Int(degrees.rounded()))° \(cardinalDirection)"
    }
}

enum QiblaCalculator {
    // Kaaba coordinates in Makkah, Saudi Arabia
    private static let kaabaLatitude: Double = 21.422487
    private static let kaabaLongitude: Double = 39.826206

    static func calculate(latitude: Double, longitude: Double) -> QiblaDirection {
        let phi1 = latitude * .pi / 180.0
        let lambda1 = longitude * .pi / 180.0
        let phi2 = kaabaLatitude * .pi / 180.0
        let lambda2 = kaabaLongitude * .pi / 180.0

        let deltaLambda = lambda2 - lambda1

        let y = sin(deltaLambda)
        let x = cos(phi1) * tan(phi2) - sin(phi1) * cos(deltaLambda)

        var azimuth = atan2(y, x) * 180.0 / .pi
        if azimuth < 0 {
            azimuth += 360.0
        }

        let cardinal = cardinalDirection(from: azimuth)
        return QiblaDirection(degrees: azimuth, cardinalDirection: cardinal)
    }

    private static func cardinalDirection(from degrees: Double) -> String {
        let directions = [
            "U", "UTL", "TL", "TTL",
            "T", "TTG", "TG", "STG",
            "S", "SBD", "BD", "BBD",
            "B", "BLB", "BL", "UBL"
        ]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }
}
