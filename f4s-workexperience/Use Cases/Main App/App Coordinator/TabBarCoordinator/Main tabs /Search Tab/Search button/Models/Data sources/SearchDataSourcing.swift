//
//  SearchDataSourcing.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import CoreLocation

protocol SearchDataSourcing : class, UITableViewDataSource {
    var userLocation: CLLocationCoordinate2D? { get set }
    func setSearchString(_ string: String?, completion: @escaping () -> Void)
    func itemForIndexPath(_ indexPath: IndexPath) -> SearchItemProtocol
}
