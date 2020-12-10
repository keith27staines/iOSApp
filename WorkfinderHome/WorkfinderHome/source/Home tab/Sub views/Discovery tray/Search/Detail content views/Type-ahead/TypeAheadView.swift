
import UIKit
import WorkfinderUI

class TypeAheadView: UIView {
    
    let filtersModel: FiltersModel
    let typeAheadDataSource: TypeAheadDataSource
    
    var didSelectText: ((String) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.tintColor = WorkfinderColors.primaryColor
        tableView.register(TypeAheadCell.self, forCellReuseIdentifier: TypeAheadCell.reuseIdentifier)
        tableView.tableFooterView = tableFooterView
        return tableView
    }()
    
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 400))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    init(filtersModel: FiltersModel, typeAheadDataSource: TypeAheadDataSource) {
        self.filtersModel = filtersModel
        self.typeAheadDataSource = typeAheadDataSource
        super.init(frame: CGRect.zero)
        configureViews()
        configureTypeAhead()
    }
    
    func configureTypeAhead() {
        typeAheadDataSource.didUpdateResults = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    func configureViews() {
        addSubview(tableView)
        backgroundColor = UIColor.white
        tableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension TypeAheadView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        typeAheadDataSource.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        typeAheadDataSource.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TypeAheadCell.reuseIdentifier) as? TypeAheadCell else {
            return UITableViewCell()
        }
        let item = typeAheadDataSource.itemForIndexPath(indexPath)
        cell.updateFrom(item)
        return cell
    }
}

extension TypeAheadView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = typeAheadDataSource.itemForIndexPath(indexPath)
        didSelectText?(item.searchTerm ?? "")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        typeAheadDataSource.sectionNameForIndex(section)
    }
}
