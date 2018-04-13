//
//  LatLon.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

/// A point containing a latitude and a longitude in decimal degrees
public typealias LatLon = CGPoint

public extension LatLon {
    
    // Calculates the greate circle distance between the current instance and `other` in meters
    public func greatCircleDistance(_ other: LatLon) -> Double {
        return LatLon.greatCircleDistance(p1:self,p2:other)
    }
    
    // Calculates the greate circle distance between two LatLons
    public static func greatCircleDistance(p1: LatLon, p2: LatLon) -> Double {
        let degreesToRadians = Double.pi / 360.0
        let r = 6371e3; // metres
        let φ1 = Double(p1.latitude) * degreesToRadians
        let φ2 = Double(p2.latitude) * degreesToRadians
        let λ1 =  Double(p1.longitude) * degreesToRadians
        let λ2 =  Double(p2.longitude) * degreesToRadians
        let Δφ = (φ2 - φ1)
        let Δλ = (λ2 - λ1)
        let a = sin(Δφ/2) * sin(Δφ/2) +
            cos(φ1) * cos(φ2) *
            sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1.0 - a))
        let d = r * c
        return d
    }
}

/// A rectangular area defined by an origin, width and height (all in decimal degrees latitude or longitude)
public typealias LatLonRect = CGRect

extension CLLocationCoordinate2D : Hashable {
    public var hashValue: Int {
        return latitude.hashValue ^ longitude.hashValue
    }
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public init(latLon: LatLon) {
        self.init(latitude: CLLocationDegrees(latLon.latitude), longitude: CLLocationDegrees(latLon.longitude))
    }
    
    /// Returns the great circle distance between the current instance and `'other` in meters
    public func greateCircleDistance(_ other: CLLocationCoordinate2D) -> Double {
        let p1 = LatLon(location: self)
        let p2 = LatLon(location: other)
        return p1.greatCircleDistance(p2)
    }
}

public extension GMSCoordinateBounds {
    public convenience init(rect: LatLonRect) {
        let soutWest = CLLocationCoordinate2D(latLon: rect.southWest)
        let northEast = CLLocationCoordinate2D(latLon: rect.northEast)
        self.init(coordinate: soutWest, coordinate: northEast)
    }
    
    public func scaledBy(fraction f: Double) -> GMSCoordinateBounds {
        let rect = LatLonRect(bounds: self)
        let scaled = rect.scaledBy(fraction: CGFloat(f))
        return GMSCoordinateBounds(rect: scaled)
    }
    
    /// Returns the diagonal distance of bounds rectangle in meters
    public func diagonalDistance() -> Double {
        return southWest.greateCircleDistance(northEast)
    }
    
    /// Returns true if the current instance is fully inside the other bounds. That is, every point of the current instance is inside the boundary of other.
    public func isFullyInside(other bounds: GMSCoordinateBounds) -> Bool {
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
    
    /// Returns the south west point of the rectangle
    public var southWest: LatLon {
        return origin
    }
    
    /// Returns the north east point of the rectangle
    public var northEast: LatLon {
        return LatLon(latitude: maxY, longitude: maxX)
    }
    
    /// Returns the center of the rectangle
    public var center: LatLon {
        return LatLon(latitude: self.midY, longitude: self.midX)
    }
    
    /// Initialize a new instance from a GMSCoordinateBounds
    public init(bounds: GMSCoordinateBounds) {
        let origin = bounds.southWest
        let width = bounds.northEast.longitude - bounds.southWest.longitude
        let height = bounds.northEast.latitude - bounds.southWest.latitude
        self.init(x: origin.longitude, y: origin.latitude, width: width, height: height)
    }
    
    /// Initializes a new instance from the southwest and north east latitudes and longitudes
    public init(southWest: LatLon, northEast: LatLon) {
        let origin = southWest
        let width = northEast.longitude - southWest.longitude
        let height = northEast.latitude - southWest.latitude
        let size = CGSize(width: width, height: height)
        self.init(origin: origin, size: size)
    }
    
    /// Returns a scaled rectangle with the same center as the current instance
    public func scaledBy(fraction f: CGFloat) -> LatLonRect {
        let center = self.center
        let width = self.width * f
        let height = self.height * f
        let southWest = LatLon(latitude: center.latitude - height / 2.0,
                               longitude: center.longitude - width / 2.0 )
        let northEast = LatLon(latitude: southWest.latitude+height,
                               longitude: southWest.longitude+width)
        return LatLonRect(southWest: southWest, northEast: northEast)
    }
}

extension LatLon {
    /// Latitude is a read-only synonym for the y value of a CGPoint
    var latitude: CGFloat {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
    
    /// Longitude is a read-only synonym for the x value of a CGPoint
    var longitude: CGFloat {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    
    /// Initialize a new LatLon from a latitude and longitude expressed in decimal degrees
    public init(latitude: CGFloat, longitude: CGFloat) {
        self.init()
        x = longitude
        y = latitude
    }
    
    /// Initialize a new LatLon from a CoreLocation 2D location
    public init(location: CLLocationCoordinate2D) {
        self.init(latitude: CGFloat(location.latitude),
                  longitude: CGFloat(location.longitude))
    }
}
