//
//  SearchResult.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import Foundation


protocol SearchItemProtocol {
    var matchOnText: String { get }
    var uuidString: String? { get }
    var primaryText: String { get }
    var secondaryText: String? { get }
    var location: CLLocationCoordinate2D? { get }
}

extension SearchItemProtocol {
    var matchOnText: String { return primaryText + (secondaryText ?? "")}
    func distanceFrom(_ target: CLLocationCoordinate2D?) -> Double? {
        guard let location = location, let target = target else { return nil }
        return location.greateCircleDistance(target)
    }
}

protocol Searchable {
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void )
}

struct SearchItem : SearchItemProtocol {
    var uuidString: String?
    
    var primaryText: String
    
    var secondaryText: String?
    
    var matchOnText: String
    
    var location: CLLocationCoordinate2D?

}




