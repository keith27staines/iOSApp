
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
        stack.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return stack
    }()
    
    @objc func reset() {
        filtersModel.clear()
        tableView.reloadData()
        titleLabel.text = titleLabelText
    }
    
    var titleLabelText: String {
        "Filters [\(filtersModel.count) active]"
    }
    
    func sectionTitleText(sectionIndex: Int) -> String {
        let collection = filtersModel.filterCollections[sectionIndex]
        return "\(collection.name) [\(collection.count) active]"
    }
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleLabelText
        return label
    }()
    
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
        tableView.register(FiltersSectionHeaderCell.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.tableFooterView = tableFooterView
        return tableView
    }()
    
    lazy var tableFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 400))
        view.backgroundColor = UIColor.white
        view.heightAnchor.constraint(equalToConstant: 400).isActive = true
        return view
    }()
    
    init(filtersModel: FiltersModel) {
        self.filtersModel = filtersModel
        super.init(frame: CGRect.zero)
        configureViews()
        loadFiltersModel()
    }
    
    func loadFiltersModel() {
        filtersModel.loadModel { [weak self] (optionalError) in
            self?.reset()
        }
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
        cell.accessoryType = filter.isSelected ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? FiltersSectionHeaderCell else { return UITableViewHeaderFooterView() }
        let tappedCollection = filtersModel.filterCollections[section]
        header.isExpanded = tappedCollection.isExpanded
        header.section = section
        header.sectionTitle.text = sectionTitleText(sectionIndex: section)
        header.onTap = { [weak self] tappedSection in
            guard let self = self else { return }
            let filtersCollection = self.filtersModel.filterCollections[tappedSection]
            filtersCollection.isExpanded.toggle()
            var changeSet = IndexSet()
            changeSet.insert(section)
            for otherSectionIndex in 0 ..< self.filtersModel.filterCollections.count {
                guard otherSectionIndex != section else { continue }
                let otherSection = self.filtersModel.filterCollections[otherSectionIndex]
                guard otherSection.isExpanded else { continue }
                otherSection.isExpanded = false
                changeSet.insert(otherSectionIndex)
            }
            header.isExpanded = filtersCollection.isExpanded
            header.sectionTitle.text = self.sectionTitleText(sectionIndex: section)
            tableView.reloadSections(changeSet, with: .automatic)
            if filtersCollection.isExpanded {
                tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
            }
            self.titleLabel.text = self.titleLabelText
        }
        return header
    }
}

extension FiltersView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let filtersCollection = filtersModel.filterCollections[indexPath.section]
        let filter = filtersCollection.filters[indexPath.row]
        filter.isSelected.toggle()
        tableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
        titleLabel.text = titleLabelText
    }
}



