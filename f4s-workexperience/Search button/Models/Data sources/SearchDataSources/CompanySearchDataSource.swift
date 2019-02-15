//
//  CompanySearchDataSource.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 08/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class SearchCompaniesFilterOperation : Operation {
    let searchString: String
    let dataFetcher: CompanySearchDataGetter
    var completion: (([SearchItemProtocol]) -> Void)?
    
    init(searchString: String, dataFetcher: CompanySearchDataGetter, completion: @escaping ([SearchItemProtocol]) -> Void) {
        self.searchString = searchString.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.dataFetcher = dataFetcher
        self.completion = completion
    }
    
    override func main() {
        if isCancelled || searchString.isEmpty {
            completion?([])
            return
        }
        dataFetcher.itemsMatching(searchString) { [weak self] (foundItems) in
            guard let strongSelf = self else { return }
            let searchString = strongSelf.searchString
            let items = foundItems
                .filter({ (searchItem) -> Bool in
                    return searchItem.matchOnText.contains(searchString)
                })
                .sorted { item1, item2 in
                    let start1 = item1.matchOnText.range(of: searchString)!.lowerBound
                    let start2 = item2.matchOnText.range(of: searchString)!.lowerBound
                    if start1 < start2 { return true }
                    if start1 > start2 { return false }
                    return item1.matchOnText < item2.matchOnText
            }
            
            if strongSelf.isCancelled {
                strongSelf.completion?([])
                return
            }
            strongSelf.completion?(items)
        }
    }
}

class CompanySearchDataSource : NSObject, SearchDataSourcing {
    
    private let dataFetcher = CompanySearchDataGetter()
    private var items = [SearchItemProtocol]()
    private var filterOperation: SearchCompaniesFilterOperation?
    private lazy var workerQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "CompanySearchDataSourceWorkerQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    var isActive: Bool {
        guard let filterOperation = filterOperation else { return false }
        return filterOperation.isExecuting
    }
    
    func setSearchString(_ string: String?, completion: @escaping () -> Void) {
        items = []
        guard let string = string else {
            completion()
            return
        }
        filterOperation?.cancel()
        filterOperation = SearchCompaniesFilterOperation(searchString: string, dataFetcher: dataFetcher, completion: { [weak self] items in
            DispatchQueue.main.async { [weak self] in
                self?.items = items
                completion()
            }
        })
        workerQueue.addOperation(filterOperation!)
    }
    
    var userLocation: CLLocationCoordinate2D?
    
    func itemForIndexPath(_ indexPath: IndexPath) -> SearchItemProtocol {
        return items[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanySearchTableViewCell") as? CompanySearchTableViewCell ?? CompanySearchTableViewCell()
        let item = itemForIndexPath(indexPath)
        cell.configure(with: item, userLocation: userLocation)
        return cell
    }
}

class CompanySearchTableViewCell : UITableViewCell {
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.minimumIntegerDigits = 1
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    init() {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "PeopleSearchTableViewCell")
    }
    
    func configure(with item: SearchItemProtocol, userLocation: CLLocationCoordinate2D?) {
        textLabel?.text = item.matchOnText.capitalized
        guard let distance = item.distanceFrom(userLocation),
            let distanceString = numberFormatter.string(from: NSNumber(value: distance/1000)) else {
            detailTextLabel?.text = ""
            return
        }
        detailTextLabel?.text = "Distance from you: \(distanceString) km"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
