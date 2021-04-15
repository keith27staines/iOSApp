//
//  PicklistPresenter.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 14/04/2021.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices


class PicklistPresenter: BaseAccountPresenter {

    let picklist: AccountPicklist
    
    init(coordinator: AccountCoordinator, service: AccountServiceProtocol, picklist: AccountPicklist) {
        self.picklist = picklist
        super.init(coordinator: coordinator, accountService: service)
    }
    
    var table: UITableView? {
        didSet {
            table?.tableHeaderView = tableheaderView
        }
    }
    
    lazy var tableheaderView: UILabel = {
        let label = UILabel()
        label.text = picklist.type.instruction
        return label
    }()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        table = tableView
        return picklist.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picklist.numberOfItemsForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = picklist.itemForIndexPath(indexPath)
        let cell = UITableViewCell()
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        picklist.sections[section]
    }
    
    override func reloadPresenter(completion: @escaping (Error?) -> Void) {
        picklist.reload(completion: completion)
    }
}
