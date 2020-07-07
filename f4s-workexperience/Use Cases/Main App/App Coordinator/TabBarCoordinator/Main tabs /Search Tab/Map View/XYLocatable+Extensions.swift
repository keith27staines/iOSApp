
import KSGeometry
import CoreLocation

extension KSXYLocatable {
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: y, longitude: x)
    }
}
