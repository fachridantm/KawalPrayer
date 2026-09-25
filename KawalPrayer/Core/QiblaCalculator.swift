import Foundation

struct QiblaDirection: Equatable {
    let degrees: Double
    let cardinalDirectionId: String
    let cardinalDirectionEn: String

    var cardinalDirection: String { cardinalDirectionId }

    func cardinalDirection(for lang: AppLanguage) -> String {
        lang == .id ? cardinalDirectionId : cardinalDirectionEn
    }

    func formattedBearing(for lang: AppLanguage = .id) -> String {
        "\(Int(degrees.rounded()))° \(cardinalDirection(for: lang))"
    }

    var formattedBearing: String {
        formattedBearing(for: .id)
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

        let idDirections = [
            "U", "UTL", "TL", "TTL",
            "T", "TTG", "TG", "STG",
            "S", "SBD", "BD", "BBD",
            "B", "BLB", "BL", "UBL"
        ]
        let enDirections = [
            "N", "NNE", "NE", "ENE",
            "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW",
            "W", "WNW", "NW", "NNW"
        ]

        let index = Int((azimuth + 11.25) / 22.5) % 16
        return QiblaDirection(
            degrees: azimuth,
            cardinalDirectionId: idDirections[index],
            cardinalDirectionEn: enDirections[index]
        )
    }
}
