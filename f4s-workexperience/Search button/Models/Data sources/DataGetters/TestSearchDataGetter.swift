//
//  SearchDataGetting.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import Foundation

class TestSearchDataGetter : Searchable {
    
    private lazy var unfiltered : [SearchItemProtocol] = {
        return TestSearchDataGetter.loadManyNames()
    }()
    
    init() {}
    
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void ) {
        DispatchQueue.main.async { [ weak self] in
            guard let strongSelf = self else { return }
            guard let searchString = searchString, !searchString.isEmpty else {
                completion([])
                return
            }
            completion(strongSelf.unfiltered)
        }
    }
    
    static func loadManyNames() -> [SearchItemProtocol] {
        guard let filepath = Bundle.main.path(forResource: "RandomNames", ofType: "csv") else {
            return []
        }
        guard let contents = try? String(contentsOfFile: filepath) else { return [] }
        return contents.split(separator: ",").compactMap({ (substring) -> SearchItem? in
            let removingLinebreaks = substring.replacingOccurrences(of: "\r\n", with: "")
            if removingLinebreaks.isEmpty { return nil }
            return SearchItem(uuidString: nil, primaryText: removingLinebreaks, secondaryText: nil, matchOnText: removingLinebreaks, location: nil)
        })
    }
}
