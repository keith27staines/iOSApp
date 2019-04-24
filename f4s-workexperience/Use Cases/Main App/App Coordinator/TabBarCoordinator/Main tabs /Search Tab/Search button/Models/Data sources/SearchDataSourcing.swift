//
//  SearchDataSourcing.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

protocol SearchDataSourcing : class, UITableViewDataSource {
    func setSearchString(_ string: String?, completion: @escaping () -> Void)
    func itemForIndexPath(_ indexPath: IndexPath) -> SearchItemProtocol
}
