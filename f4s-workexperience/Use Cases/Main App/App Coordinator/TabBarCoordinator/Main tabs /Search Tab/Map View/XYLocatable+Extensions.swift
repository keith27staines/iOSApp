
import CoreLocation

extension XYLocatable {
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: y, longitude: x)
    }
}
