//
//  MapModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 01/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation

/// A rectangular area defined by an origin, width and height (all in decimal degrees latitude or longitude)
public typealias LatLonRect = CGRect

// MARK:-
public struct MapModel {
    
    /// The current bounds of the visible portion of the map
    public var currentBounds: GMSCoordinateBounds? = nil
    
    /// The interests are used to filter the companies to be shown on the map
    public var selectedInterestsIds: Set<UInt64>? = nil
}

// MARK:- public API for getting companies
public extension MapModel {
    
    /// Gets companies within the rectangular area specified by bounds and filtered by selectedInterests
    ///
    /// - parameter bounds: The area to be searched
    /// - parameter completion: Called to return the companies within bounds and matching on one or more interests
    public func getFilteredCompaniesInsideBounds(_ bounds: GMSCoordinateBounds, completion:([Company]) -> Void) {
        
        getCompaniesInsideBounds(bounds) { (companies) in
            
            guard let filters = selectedInterestsIds else {
                // No filters to apply so pass the entire set to the completion handler
                completion(companies)
                return
            }
            let filtered = companies.filter({ (company) -> Bool in
                // If a company interest matches one of the filter interests, then it is to be included in the filtered set
                return !company.interestIds.intersection(filters).isEmpty
            })
            // pass the filtered set to the completion handler
            completion(filtered)
        }
    }
    
    /// Gets all companies within the rectangular area specified by bounds
    ///
    /// - parameter bounds: The area to be searched
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideBounds(_ bounds: GMSCoordinateBounds, completion:([Company]) -> Void) {
        completion([])
    }
    
    /// Gets companies within the current bounds and filtered by selectedInterests
    ///
    /// - parameter completion: Called to return the companies within bounds and matching the filters
    public func getFilteredCompaniesInsideCurrentBounds(completion:([Company]) -> Void) {
        
        getCompaniesInsideCurrentBounds { (companies) in
            
            guard let filters = selectedInterestsIds else {
                // No filters to apply so pass the entire set to the completion handler
                completion(companies)
                return
            }
            let filtered = companies.filter({ (company) -> Bool in
                // If a company interest matches one of the filter interests, then it is to be included in the filtered set
                return !company.interestIds.intersection(filters).isEmpty
            })
            // pass the filtered set to the completion handler
            completion(filtered)
        }
    }
    
    /// Gets all companies within the rectangular area represented by the current bounds
    ///
    /// - parameter completion: Called to return the companies within bounds
    public func getCompaniesInsideCurrentBounds(completion: ([Company]) -> Void) {
        guard let currentBounds = currentBounds else {
            // As there are no current bounds we return an empty collection
            completion([])
            return
        }
        getCompaniesInsideBounds(currentBounds, completion: completion)
    }
}

// MARK:- public API for getting interests
public extension MapModel {
    
    /// Gets interests within the rectangular area specified by bounds
    ///
    /// - parameter bounds: The area to be searched
    /// - parameter completion: Called to return the interests within bounds
    public func getInterestsInsideBounds(_ bounds: GMSCoordinateBounds, completion:([Interest]) -> Void) {
        completion([])
    }

    /// Gets all interests within the rectangular area represented by the current bounds
    ///
    /// - parameter completion: Called to return the interests within bounds
    public func getInterestsInsideCurrentBounds(completion: ([Interest]) -> Void) {
        guard let currentBounds = currentBounds else {
            completion([])
            return
        }
        getInterestsInsideBounds(currentBounds, completion: completion)
    }
}

// MARK:- helper methods
extension MapModel {
    /// Transforms the specified coordinate bounds into a LatLonRect (alias for CGRect)
    static func latLonRectFrom(_ bounds: GMSCoordinateBounds) -> LatLonRect {
        let southWestLongitude = bounds.southWest.longitude
        let southWestLatitude = bounds.southWest.latitude
        let northEastLongitude = bounds.northEast.longitude
        let northEastLatitude = bounds.northEast.latitude
        return CGRect(x: southWestLongitude,
                      y: southWestLatitude,
                      width: northEastLongitude-southWestLongitude,
                      height: northEastLatitude - southWestLatitude)
    }
}


