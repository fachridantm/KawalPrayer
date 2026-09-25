import Foundation

struct LocationModel: Codable, Equatable {
    var latitude : Double
    var longitude: Double
    var cityName : String
    var timezone : Double

    static let defaultLocation = LocationModel(
        latitude : -6.1754,
        longitude: 106.8272,
        cityName : "Central Jakarta, Gambir",
        timezone : 7.0
    )
}
