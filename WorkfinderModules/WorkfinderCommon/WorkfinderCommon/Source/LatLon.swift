//
//  LatLon.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/10/2017.
//  Copyright © 2017 Workfinder Ltd. All rights reserved.
//

import Foundation
import CoreLocation

/// A point containing a latitude and a longitude in decimal degrees
public struct LatLon: Equatable {
    public var latitude: CGFloat
    public var longitude: CGFloat
    
    public init(latitude: CGFloat, longitude: CGFloat) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initialize a new LatLon from a CoreLocation 2D location
    public init(location: CLLocationCoordinate2D) {
        self.init(latitude: CGFloat(location.latitude), longitude: CGFloat(location.longitude))
    }
}

public extension LatLon {
    
    // Calculates the greate circle distance between the current instance and `other` in meters
    func greatCircleDistance(_ other: LatLon) -> Double {
        return LatLon.greatCircleDistance(p1:self,p2:other)
    }
    
    // Calculates the greate circle distance between two LatLons
    static func greatCircleDistance(p1: LatLon, p2: LatLon) -> Double {
        let degreesToRadians = Double.pi / 180.0
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

extension CLLocationCoordinate2D {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
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

public extension LatLonRect {
    
    /// Returns the south west point of the rectangle
    var southWest: LatLon {
        return LatLon(latitude: minY, longitude: minX)
    }
    
    /// Returns the north east point of the rectangle
    var northEast: LatLon {
        return LatLon(latitude: maxY, longitude: maxX)
    }
    
    /// Returns the center of the rectangle
    var center: LatLon {
        return LatLon(latitude: self.midY, longitude: self.midX)
    }
    
    /// Initializes a new instance from the southwest and north east latitudes and longitudes
    init(southWest: LatLon, northEast: LatLon) {
        let origin = CGPoint(x: southWest.longitude, y: southWest.latitude)
        let width = northEast.longitude - southWest.longitude
        let height = northEast.latitude - southWest.latitude
        let size = CGSize(width: width, height: height)
        self.init(origin: origin, size: size)
    }
    
    /// Returns a scaled rectangle with the same center as the current instance
    func scaledBy(fraction f: CGFloat) -> LatLonRect {
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
