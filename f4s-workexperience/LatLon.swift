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
}

public extension LatLonRect {
    
    /// Returns the south west point of the rectangle
    public var southWest: LatLon {
        return origin
    }
    
    /// Returns the north east point of the rectangle
    public var northEast: LatLon {
        return LatLon(latitude: maxX, longitude: maxX)
    }
    
    /// Returns the center of the rectangle
    public var center: LatLon {
        return LatLon(latitude: self.midY, longitude: self.midY)
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
        x = longitude
        y = latitude
    }
    
    /// Initialize a new LatLon from a CoreLocation 2D location
    public init(location: CLLocationCoordinate2D) {
        self.init(latitude: CGFloat(location.latitude),
                  longitude: CGFloat(location.longitude))
    }
}
