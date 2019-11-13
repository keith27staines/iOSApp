//
//  PeopleDataSource.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class PeopleSearchDataSource : NSObject, SearchDataSourcing {
    var userLocation: CLLocationCoordinate2D?
    private let dataFetcher = TestSearchDataGetter()
    private var items = [SearchItemProtocol]()
    
    func setSearchString(_ string: String?, completion: @escaping () -> Void) {
        dataFetcher.itemsMatching(string) { [weak self] (foundItems) in
            guard let string = string else {
                self?.items = []
                completion()
                return
            }
            self?.items = foundItems
                .filter({ (searchItem) -> Bool in
                    return searchItem.matchOnText.lowercased().contains(string.lowercased())
                })
                .sorted { return $0.matchOnText.lowercased() < $1.matchOnText.lowercased() }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleSearchTableViewCell") as? PeopleSearchTableViewCell ?? PeopleSearchTableViewCell()
        let item = itemForIndexPath(indexPath)
        cell.configure(with: item)
        return cell
    }
}

class PeopleSearchTableViewCell : UITableViewCell {
    
    init() {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PeopleSearchTableViewCell")
    }
    
    func configure(with item: SearchItemProtocol) {
        textLabel?.text = item.matchOnText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
