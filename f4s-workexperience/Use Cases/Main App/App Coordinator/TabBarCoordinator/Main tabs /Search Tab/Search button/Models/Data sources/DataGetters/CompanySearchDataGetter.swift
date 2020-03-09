//
//  CompanySearchDataGetter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

extension Company : SearchItemProtocol {
    var location: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var uuidString: String? {
        return uuid
    }
    
    var primaryText: String {
        return name
    }
    
    var secondaryText: String? {
        return nil
    }
    
    var matchOnText: String { return sortingName }
}

class CompanySearchDataGetter : Searchable {
    
    var unfiltered : [SearchItemProtocol]?
    
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void) {
        if let unfiltered = unfiltered {
            completion(unfiltered)
            return
        }
        completion([])
    }
}
