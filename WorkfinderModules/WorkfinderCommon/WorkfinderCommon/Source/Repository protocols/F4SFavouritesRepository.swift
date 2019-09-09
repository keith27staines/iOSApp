//
//  F4SFavouritesRepository.swift
//  WorkfinderCommon
//
//  Created by Keith Dev on 09/09/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation

public protocol FavouritesRepositoryProtocol {
    func loadFavourites() -> [Shortlist]
    func removeFavourite(uuid: F4SUUID)
    func addFavourite(_ item: Shortlist)
}
