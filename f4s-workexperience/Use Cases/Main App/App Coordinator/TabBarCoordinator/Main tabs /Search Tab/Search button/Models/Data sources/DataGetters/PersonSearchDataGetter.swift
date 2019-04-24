//
//  PersonSearchDataGetter.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 10/02/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation


class PersonSearchDataGetter : Searchable {
    func itemsMatching(_ searchString: String?, completion: @escaping ([SearchItemProtocol]) -> Void) {
        completion([])
    }
    
}
