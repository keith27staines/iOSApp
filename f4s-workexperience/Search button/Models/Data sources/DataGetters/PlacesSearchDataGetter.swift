//
//  PlacesSearchDataGetter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import GooglePlaces

extension GMSAutocompletePrediction : SearchItemProtocol {
    var uuidString: String? {
        return placeID
    }
    
    var primaryText: String {
        return attributedPrimaryText.string
    }
    
    var secondaryText: String? {
        return attributedSecondaryText?.string
    }
    
    var matchOnText: String {
        return primaryText.lowercased()
    }
    
    
}

class PlacesSearchDataGetter : Searchable {
    
    // autocomplete places api setup
    let placesClient = GMSPlacesClient()
    
    let autoCompleteFilter: GMSAutocompleteFilter = {
        let autoCompleteFilter = GMSAutocompleteFilter()
        autoCompleteFilter.country = "gb"
        return autoCompleteFilter
    }()

    var predictions = [GMSAutocompletePrediction]()
    
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void) {
        guard let searchString = searchString else {
            completion([])
            return
        }
        placesClient.autocompleteQuery(searchString, bounds: nil, filter: autoCompleteFilter, callback: { [weak self]  results, error in
            guard let strongSelf = self else { return }
            strongSelf.predictions = results ?? []
            completion(strongSelf.predictions)
        })
    }
}
