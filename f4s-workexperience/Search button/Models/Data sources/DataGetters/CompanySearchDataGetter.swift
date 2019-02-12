//
//  CompanySearchDataGetter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

extension Company : SearchItemProtocol {
    var uuidString: String? {
        return uuid
    }
    
    
    var primaryText: String {
        return name
    }
    
    var secondaryText: String? {
        return nil
    }
    
    var matchOnText: String { return name.lowercased() }
}

class CompanySearchDataGetter : Searchable {
    
    var unfiltered : [SearchItemProtocol]?
    
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void) {
        if let unfiltered = unfiltered {
            completion(unfiltered)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            let dbOps = DatabaseOperations.sharedInstance
            dbOps.getAllCompanies { companies in
                DispatchQueue.main.async {
                    strongSelf.unfiltered = companies
                    completion(companies)
                }
            }
        }
    }
}
