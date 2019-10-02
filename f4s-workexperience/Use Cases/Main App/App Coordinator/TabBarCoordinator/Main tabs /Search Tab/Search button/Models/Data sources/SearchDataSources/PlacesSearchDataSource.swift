//
//  LocationSearchDataSource.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class PlacesSearchDataSource : NSObject, SearchDataSourcing {
    var userLocation: CLLocationCoordinate2D?
    private lazy var dataFetcher = PlacesSearchDataGetter()
    private var items = [SearchItemProtocol]()
    
    func setSearchString(_ string: String?, completion: @escaping () -> Void) {
        guard let string = string, string.count >= 3 else {
            items = []
            completion()
            return
        }
        dataFetcher.itemsMatching(string) { [weak self] (foundItems) in
            self?.items = foundItems
            completion()
        }
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> SearchItemProtocol {
        return items[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchTableViewCell") as? LocationSearchTableViewCell ?? LocationSearchTableViewCell()
        let item = itemForIndexPath(indexPath)
        cell.configure(with: item)
        return cell
    }
}

class LocationSearchTableViewCell : UITableViewCell {
    
    init() {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "LocationSearchTableViewCell")
    }
    
    func configure(with item: SearchItemProtocol) {
        textLabel?.text = item.primaryText
        detailTextLabel?.text = item.secondaryText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
