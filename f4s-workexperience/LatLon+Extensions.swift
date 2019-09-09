import Foundation
import WorkfinderCommon

public extension GMSCoordinateBounds {
    convenience init(rect: LatLonRect) {
        let soutWest = CLLocationCoordinate2D(latLon: rect.southWest)
        let northEast = CLLocationCoordinate2D(latLon: rect.northEast)
        self.init(coordinate: soutWest, coordinate: northEast)
    }

    func scaledBy(fraction f: Double) -> GMSCoordinateBounds {
        let rect = LatLonRect(bounds: self)
        let scaled = rect.scaledBy(fraction: CGFloat(f))
        return GMSCoordinateBounds(rect: scaled)
    }

    /// Returns the diagonal distance of bounds rectangle in meters
    func diagonalDistance() -> Double {
        return southWest.greateCircleDistance(northEast)
    }

    /// Returns true if the current instance is fully inside the other bounds. That is, every point of the current instance is inside the boundary of other.
    func isFullyInside(other bounds: GMSCoordinateBounds) -> Bool {
        if !bounds.contains(self.southWest) || !bounds.contains(self.northEast) {
            return false
        }
        if self.southWest == bounds.southWest || self.northEast == bounds.northEast {
            return false
        }
        return true
    }
}

public extension LatLonRect {
    /// Initialize a new instance from a GMSCoordinateBounds
    init(bounds: GMSCoordinateBounds) {
        let origin = bounds.southWest
        let width = bounds.northEast.longitude - bounds.southWest.longitude
        let height = bounds.northEast.latitude - bounds.southWest.latitude
        self.init(x: origin.longitude, y: origin.latitude, width: width, height: height)
    }
}
