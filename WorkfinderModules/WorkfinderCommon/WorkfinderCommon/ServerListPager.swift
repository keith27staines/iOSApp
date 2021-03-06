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
    private(set) var _count: Int = 0
    private var canLoadNextPage: Bool {
        _nextPage != nil && items.count < _count && isLoading == false ? true : false
    }
    
    public var nextPage: String? { canLoadNextPage ? _nextPage : nil }
    public private(set) var items = [A]()
    public var triggerRow: Int { items.count - pageSize / 2}
    public var isLoading = false
    var section: Int = 0
    public init() {}

    private func reset(table: UITableView) {
        _count = 0
        _nextPage = nil
        isLoading = false
        items = []
        let indexSet = IndexSet(integer: section)
        table.reloadSections(indexSet, with: .automatic)
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
        precondition(_count > 0)
        load(table: table, with: serverListResult, completion: completion)
    }
    
    private func load(
        table: UITableView,
        with serverListResult: Result<ServerListJson<A>,Error>,
        completion: @escaping ((Error?) -> Void) = {_ in }
    ) {
        switch serverListResult {
        case .success(let serverListJson):
            _count = serverListJson.count ?? 0
            _nextPage = serverListJson.next
            let currentItemCount = self.items.count
            let addedIndexPaths = IndexSet(integersIn:
                currentItemCount..<currentItemCount+serverListJson.results.count).map {
                IndexPath(row: $0, section: section)
            }
            self.items += serverListJson.results
            if currentItemCount == 0 {
                table.reloadData()
            } else {
                table.insertRows(at: addedIndexPaths, with: .bottom)
            }
            isLoading = false
            completion(nil)
        case .failure(let error):
            isLoading = false
            completion(error)
        }
    }

}
