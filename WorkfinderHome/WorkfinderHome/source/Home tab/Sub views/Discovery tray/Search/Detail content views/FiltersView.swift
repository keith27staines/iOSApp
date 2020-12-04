
import UIKit
import WorkfinderUI

class FiltersView: UIView {
    
    let filtersModel: FiltersModel
    
    lazy var topStack: UIStackView = {
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        let stack = UIStackView()
        stack.addArrangedSubview(leftSpacer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(rightSpacer)
        stack.addArrangedSubview(resetButton)
        stack.axis = .horizontal
        leftSpacer.widthAnchor.constraint(equalTo: rightSpacer.widthAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return stack
    }()
    
    @objc func reset() {
        
    }
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.tintColor = WorkfinderColors.primaryColor
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filters"
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.register(FiltersSectionHeaderCell.self, forHeaderFooterViewReuseIdentifier: "header")
        return tableView
    }()
    
    init(filtersModel: FiltersModel = FiltersModel()) {
        self.filtersModel = filtersModel
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    func configureViews() {
        addSubview(topStack)
        addSubview(tableView)
        backgroundColor = UIColor.white
        topStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        tableView.anchor(top: topStack.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension FiltersView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        filtersModel.filterCollections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filtersCollection = filtersModel.filterCollections[section]
        return filtersCollection.isExpanded ? filtersCollection.filters.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filtersCollection = filtersModel.filterCollections[indexPath.section]
        let filter = filtersCollection.filters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "") ?? UITableViewCell()
        cell.textLabel?.text = filter.type.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? FiltersSectionHeaderCell else { return UITableViewHeaderFooterView() }
        let filtersCollection = filtersModel.filterCollections[section]
        header.section = section
        header.sectionTitle.text = filtersCollection.name
        header.onTap = { [weak self] tappedSection in
            guard let self = self else { return }
            let filtersCollection = self.filtersModel.filterCollections[tappedSection]
            filtersCollection.isExpanded.toggle()
            tableView.reloadSections(IndexSet([section]), with: .automatic)
        }
        return header
    }
}

extension FiltersView: UITableViewDelegate {

}



