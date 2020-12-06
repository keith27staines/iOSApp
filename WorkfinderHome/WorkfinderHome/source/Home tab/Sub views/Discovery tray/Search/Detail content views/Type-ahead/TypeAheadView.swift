
import UIKit
import WorkfinderUI

class TypeAheadView: UIView {
    
    let filtersModel: FiltersModel
    let typeAheadDataSource: TypeAheadDataSource
    
    var didSelectText: ((String) -> Void)?
    
    lazy var topStack: UIStackView = {
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        let stack = UIStackView()
        stack.addArrangedSubview(leftSpacer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(rightSpacer)
        stack.axis = .horizontal
        leftSpacer.widthAnchor.constraint(equalTo: rightSpacer.widthAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            let matchCount = self.typeAheadDataSource.results.count
            if self.typeAheadDataSource.string?.count ?? 0 > 2 {
                self.titleLabel.text = "Type-ahead matches (\(matchCount))"
            } else {
                self.titleLabel.text = "Please enter 3 or more characters"
            }
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

extension TypeAheadView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        typeAheadDataSource.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        typeAheadDataSource.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = typeAheadDataSource.results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = result
        return cell
    }
}

extension TypeAheadView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectText?(typeAheadDataSource.results[indexPath.row])
    }
}
