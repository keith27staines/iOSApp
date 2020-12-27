//
//  LatLonTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith Dev on 28/01/2020.
//  Copyright © 2020 Workfinder Ltd. All rights reserved.
//

import XCTest
@testable import WorkfinderCommon
import CoreLocation

fileprivate let r = 6371e3; // radius of earth in metres

class LatLonTests: XCTestCase {
    
    func test_get_latitude_and_longitude() {
        let pt = LatLon(latitude: 17, longitude: 27)
        XCTAssertEqual(pt.longitude, pt.longitude)
        XCTAssertEqual(pt.latitude, pt.latitude)
        XCTAssertEqual(pt.latitude, 17)
        XCTAssertEqual(pt.longitude, 27)
    }
    
    func test_set_latitude_and_longitude() {
        var pt = LatLon(latitude: 0, longitude: 0)
        pt.latitude = 17
        pt.longitude = 27
        XCTAssertEqual(pt.longitude, pt.longitude)
        XCTAssertEqual(pt.latitude, pt.latitude)
    }
    
    func testGreatCircleDistance_coincident_points() {
        let pt1 = LatLon(latitude:0.0,longitude:0.0)
        let pt2 = LatLon(latitude:0.0,longitude:0.0)
        XCTAssertEqual(pt1.greatCircleDistance(pt2), 0.0)
    }
    
    func testGreatCircleDistance_90_degrees_apart_in_latitude() {
        let pt1 = LatLon(latitude:0.0,longitude:0.0)
        let pt2 = LatLon(latitude:90.0,longitude:0.0)
        XCTAssertEqual(pt1.greatCircleDistance(pt2), 2.0 * Double.pi * r / 4.0, accuracy: 1)
    }
    
    func testGreatCircleDistance_90_degrees_apart_in_longitude() {
        let pt1 = LatLon(latitude:0.0,longitude:0.0)
        let pt2 = LatLon(latitude:0.0,longitude:90.0)
        XCTAssertEqual(pt1.greatCircleDistance(pt2), 2.0 * Double.pi * r / 4.0, accuracy: 1)
    }
}

class CLLocationCoordinate2DExtensionTests: XCTestCase {
    
    func testInit_from_latlon() {
        let latlon = LatLon(latitude: 23, longitude: 49)
        let location = CLLocationCoordinate2D(latLon: latlon)
        XCTAssertEqual(location.latitude, CLLocationDegrees(latlon.latitude))
        XCTAssertEqual(location.longitude, CLLocationDegrees(latlon.longitude))
    }
    
    
    func testGreatCircleDistance_90_degrees_apart_in_latitude() {
        let pt1 = LatLon(latitude:0.0,longitude:0.0)
        let pt2 = LatLon(latitude:90.0,longitude:0.0)
        let location1 = CLLocationCoordinate2D(latLon: pt1)
        let location2 = CLLocationCoordinate2D(latLon: pt2)
        XCTAssertEqual(location1.greateCircleDistance(location2), 2.0 * Double.pi * r / 4.0, accuracy: 1)
    }
    
}

class LatLonRectTests: XCTestCase {
    let southwest = LatLon(latitude: 0, longitude: 20)
    let northwest = LatLon(latitude: 10, longitude: 20)
    let southeast = LatLon(latitude: 0, longitude: 40)
    let northeast = LatLon(latitude: 10, longitude: 40)
    
    func test_rect_center() {
        let rect = LatLonRect(southWest: southwest, northEast: northeast)
        let center = rect.center
        XCTAssertEqual(center.latitude, 5)
        XCTAssertEqual(center.longitude, 30)
    }
    
    func test_corners() {
        let rect = LatLonRect(southWest: southwest, northEast: northeast)
        XCTAssertEqual(rect.southWest, southwest)
        XCTAssertEqual(rect.northEast, northeast)
    }
    
    func test_scaledBy() {
        let rect = LatLonRect(southWest: southwest, northEast: northeast)
        let scaledRect = rect.scaledBy(fraction: 0.5)
        XCTAssertEqual(scaledRect.center, rect.center)
        XCTAssertEqual(scaledRect.height, rect.height/2)
        XCTAssertEqual(scaledRect.width, rect.width/2)
    }
    

}


