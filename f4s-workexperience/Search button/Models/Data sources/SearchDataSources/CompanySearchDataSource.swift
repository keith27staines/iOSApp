//
//  CompanySearchDataSource.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class CompanySearchDataSource : NSObject, SearchDataSourcing {
    
    private let dataFetcher = CompanySearchDataGetter()
    private var items = [SearchItemProtocol]()
    
    func setSearchString(_ string: String?, completion: @escaping () -> Void) {
        dataFetcher.itemsMatching(string) { [weak self] (foundItems) in
            guard let string = string else {
                self?.items = []
                completion()
                return
            }
            let lowercasedSearch = string.lowercased()
            self?.items = foundItems
                .filter({ (searchItem) -> Bool in
                    return searchItem.matchOnText.lowercased().contains(lowercasedSearch)
                })
                .sorted { item1, item2 in
                    let lowercaseMatch1 = item1.matchOnText.lowercased()
                    let lowercaseMatch2 = item2.matchOnText.lowercased()
                    let start1 = lowercaseMatch1.range(of: lowercasedSearch)!.lowerBound
                    let start2 = lowercaseMatch2.range(of: lowercasedSearch)!.lowerBound
                    if start1 < start2 { return true }
                    if start1 > start2 { return false }
                    return item1.matchOnText.lowercased() < item2.matchOnText.lowercased()
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanySearchTableViewCell") as? CompanySearchTableViewCell ?? CompanySearchTableViewCell()
        let item = itemForIndexPath(indexPath)
        cell.configure(with: item)
        return cell
    }
}

class CompanySearchTableViewCell : UITableViewCell {
    
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
