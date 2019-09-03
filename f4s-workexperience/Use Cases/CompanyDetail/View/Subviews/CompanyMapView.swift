//
//  CompanyMapView.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import MapKit
import WorkfinderCommon

class CompanyMapView: MKMapView {
    let company: Company
    init(company: Company) {
        self.company = company
        super.init(frame: CGRect.zero)
        addAnnotation(F4SCompanyAnnotation(company: company))
        showsScale = true
        showsCompass = true
        showsUserLocation = true
    }
    
    lazy var companyLoc = CLLocation(latitude: company.latitude, longitude: company.longitude)
    
    func prepareForDisplay() {
        var minimumRegionMeters = CLLocationDistance(exactly:1000.0)!
        let minumumRegion: MKCoordinateRegion
        if let userLocation = userLocation.location {
            // as the user's location is known, center on their coordinate and make sure the map scale is small enough to display the company
            minimumRegionMeters = 1.5 * max(2.0 * userLocation.distance(from: companyLoc), minimumRegionMeters)
            minumumRegion = MKCoordinateRegion.init(center: userLocation.coordinate, latitudinalMeters: minimumRegionMeters, longitudinalMeters: minimumRegionMeters)
        } else {
            // as the user's coordinate is not known, show a small area centered on the map
            minumumRegion = MKCoordinateRegion.init(center: companyLoc.coordinate, latitudinalMeters: minimumRegionMeters, longitudinalMeters: minimumRegionMeters)
        }
        let adjustedRegion = regionThatFits(minumumRegion)
        setRegion(adjustedRegion, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class F4SCompanyAnnotation : MKPointAnnotation  {
    init(company: Company) {
        super.init()
        title = company.name
        coordinate = CLLocationCoordinate2D(latitude: company.latitude, longitude: company.longitude)
    }
}
