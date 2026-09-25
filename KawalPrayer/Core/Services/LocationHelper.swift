import CoreLocation
import Foundation

public enum LocationHelper {

    /// Formats a CLPlacemark into "City/Locality, District/Kecamatan"
    /// Example: "Central Jakarta, Gambir" or "Bandung, Coblong"
    public static func formatCityAndDistrict(from place: CLPlacemark) -> String {
        let city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea
        let district = place.subLocality
        return formatCityAndDistrict(city: city, district: district)
    }

    /// Pure formatting function taking optional city and district strings
    public static func formatCityAndDistrict(
        city: String?,
        district: String?
    ) -> String {
        switch (city, district) {
        case let (.some(c), .some(d)) where !c.isEmpty && !d.isEmpty:
            let trimmedCity = c.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDistrict = d.trimmingCharacters(in: .whitespacesAndNewlines)

            // If city and district are identical, don't duplicate (e.g. "Singapore, Singapore" -> "Singapore")
            if trimmedCity.caseInsensitiveCompare(trimmedDistrict) == .orderedSame {
                return trimmedCity
            }

            return "\(trimmedCity), \(trimmedDistrict)"

        case let (.some(c), _) where !c.isEmpty:
            return c.trimmingCharacters(in: .whitespacesAndNewlines)

        case let (_, .some(d)) where !d.isEmpty:
            return d.trimmingCharacters(in: .whitespacesAndNewlines)

        default:
            return "Central Jakarta, Gambir"
        }
    }
}
