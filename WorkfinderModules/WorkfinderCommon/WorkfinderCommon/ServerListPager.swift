//
//  ServerListPager.swift
//  WorkfinderCommon
//
//  Created by Keith Staines on 03/02/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit

public class ServerListPager<A> where A: Codable {
    private var _nextPage: String?
    private let pageSize = 40
    private(set) var count: Int = 0
    private var canLoadNextPage: Bool {
        _nextPage != nil && items.count < count && isLoading == false ? true : false
    }
    
    public var nextPage: String? { canLoadNextPage ? _nextPage : nil }
    public private(set) var items = [A]()
    public var triggerRow: Int { items.count - pageSize / 2}
    public var isLoading = false

    public init() {}

    private func reset(table: UITableView) {
        count = 0
        _nextPage = nil
        isLoading = false
        items = []
        table.reloadData()
    }
    
    public func loadFirstPage(
        table: UITableView,
        with serverListResult: Result<ServerListJson<A>,Error>,
        completion: @escaping ((Error?) -> Void) = {_ in }
    ) {
        reset(table: table)
        load(table: table, with: serverListResult, completion: completion)
    }
    
    public func loadNextPage(
        table: UITableView,
        with serverListResult: Result<ServerListJson<A>,Error>,
        completion: @escaping ((Error?) -> Void) = {_ in }
    ) {
        precondition(count > 0)
        load(table: table, with: serverListResult, completion: completion)
    }
    
    private func load(
        table: UITableView,
        with serverListResult: Result<ServerListJson<A>,Error>,
        completion: @escaping ((Error?) -> Void) = {_ in }
    ) {
        switch serverListResult {
        case .success(let serverListJson):
            count = serverListJson.count ?? 0
            _nextPage = serverListJson.next
            let currentItemCount = self.items.count
            let addedIndexPaths = IndexSet(integersIn:
                currentItemCount..<currentItemCount+serverListJson.results.count).map {
                IndexPath(row: $0, section: 0)
            }
            self.items += serverListJson.results
            table.insertRows(at: addedIndexPaths, with: .bottom)
            isLoading = false
            completion(nil)
        case .failure(let error):
            isLoading = false
            completion(error)
        }
    }

}
