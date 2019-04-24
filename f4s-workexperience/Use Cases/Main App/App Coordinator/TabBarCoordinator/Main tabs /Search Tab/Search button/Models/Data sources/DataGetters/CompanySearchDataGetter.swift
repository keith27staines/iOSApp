//
//  CompanySearchDataGetter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            
            let dbOps = DatabaseOperations.sharedInstance
            dbOps.getAllCompanies { companies in
                strongSelf.unfiltered = companies
                completion(companies)
            }
        }
    }
}
