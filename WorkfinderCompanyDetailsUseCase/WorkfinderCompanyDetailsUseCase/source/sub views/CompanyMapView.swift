//
//  CompanyMapView.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/02/2019.
//  Copyright © 2019 Workfinder Ltd. All rights reserved.
//

import MapKit
import WorkfinderCommon

class CompanyMapView: MKMapView {
    let companyLatLon: LatLon
    let companyName: String
    
    init(companyName: String, companyLatLon: LatLon) {
        self.companyName = companyName
        self.companyLatLon = companyLatLon
        super.init(frame: CGRect.zero)
        let annotation = F4SCompanyAnnotation(companyName: companyName, latLon: companyLatLon)
        addAnnotation(annotation)
        showsScale = true
        showsCompass = true
        showsUserLocation = true
    }
    
    var companyLocation: CLLocation { CLLocation(latlon: self.companyLatLon) }
    
    func prepareForDisplay() {
        var minimumRegionMeters = CLLocationDistance(exactly:1000.0)!
        let minumumRegion: MKCoordinateRegion
        if let userLocation = userLocation.location {
            // as the user's location is known, center on their coordinate and make sure the map scale is small enough to display the company
            minimumRegionMeters = 1.5 * max(2.0 * userLocation.distance(from: companyLocation), minimumRegionMeters)
            minumumRegion = MKCoordinateRegion.init(center: userLocation.coordinate, latitudinalMeters: minimumRegionMeters, longitudinalMeters: minimumRegionMeters)
        } else {
            // as the user's coordinate is not known, show a small area centered on the map
            minumumRegion = MKCoordinateRegion.init(center: companyLocation.coordinate, latitudinalMeters: minimumRegionMeters, longitudinalMeters: minimumRegionMeters)
        }
        let adjustedRegion = regionThatFits(minumumRegion)
        setRegion(adjustedRegion, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class F4SCompanyAnnotation : MKPointAnnotation  {
    init(companyName: String, latLon: LatLon) {
        super.init()
        title = companyName
        coordinate = CLLocationCoordinate2D(latLon: latLon)
    }
}

extension CLLocation {
    convenience init(pin: LocationPin) {
        self.init(latitude: pin.lat, longitude: pin.lon)
    }
    
    convenience init(latlon: LatLon) {
        self.init(
            latitude: CLLocationDegrees(latlon.latitude),
            longitude: CLLocationDegrees(latlon.longitude))
    }
}

extension CLLocationCoordinate2D {
    init(pin: LocationPin) {
        self.init(latitude: pin.lat, longitude: pin.lon)
    }
}
