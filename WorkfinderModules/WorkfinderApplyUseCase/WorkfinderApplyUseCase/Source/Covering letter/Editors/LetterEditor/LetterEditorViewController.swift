
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol LetterEditorCoordinatorProtocol: class {
    func start()
    func letterEditorDidComplete(view: LetterEditorViewProtocol)
    func showPicklist(_ picklist: PicklistProtocol)
}

protocol LetterEditorViewProtocol: class {
    func refresh()
}

class LetterEditorViewController: UIViewController, LetterEditorViewProtocol {
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: LetterEditorPresenterProtocol
    
    func refresh() {
        tableView.reloadData()
        if let error = presenter.consistencyError {
            switch error.errorType {
            case .custom(let title, description: let description):
                let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            default:
                messageHandler.displayOptionalErrorIfNotNil(error, cancelHandler: nil, retryHandler: nil)
            }
            
        }
    }
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.tableView
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(PicklistCell.self, forCellReuseIdentifier: "evencell")
        tableView.register(PicklistDescriptionCell.self, forCellReuseIdentifier: "oddcell")
        tableView.register(SectionHeaderCell.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(SectionFooterCell.self, forHeaderFooterViewReuseIdentifier: "footer")
        tableView.sectionFooterHeight = UITableView.automaticDimension
        return tableView
    }()
    
    lazy var updateLetterButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Update letter", for: .normal)
        button.addTarget(self, action: #selector(updateLetter), for: .touchUpInside)
        return button
    }()
    
    @objc func updateLetter() { navigationController?.popViewController(animated: true) }
    
    func configureViews() {
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        view.addSubview(updateLetterButton)
        mainStack.anchor(top: safeArea.topAnchor, leading: safeArea.leadingAnchor, bottom: nil, trailing: safeArea.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        updateLetterButton.anchor(top: mainStack.bottomAnchor, leading: safeArea.leadingAnchor, bottom: safeArea.bottomAnchor, trailing: safeArea.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureViews()
        tableView.dataSource = self
        tableView.delegate = self
        presenter.onViewDidLoad(view: self)
        navigationItem.title = "Select values"
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.onViewDidAppear()
        refresh()
    }
    
    func loadData() {
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError, cancelHandler: {
                self.refresh()
            }) {
                self.loadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent { presenter.onDidDismiss() }
    }
    
    init(presenter: LetterEditorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LetterEditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row.isMultiple(of: 2)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row.isMultiple(of: 2) {
            let picklist = presenter.picklist(for: indexPath)
            presenter.showPicklist(picklist)
        }
    }
}

extension LetterEditorViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row.isMultiple(of: 2) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "evencell") as? PicklistCell else {
                return UITableViewCell()
            }
            let picklist = presenter.picklist(for: indexPath)
            cell.configureWithPicklist(picklist)
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "oddcell") as? PicklistDescriptionCell else {
                return UITableViewCell()
            }
            let picklist = presenter.picklist(for: indexPath)
            cell.configureWithPicklist(picklist)
            cell.accessoryType = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderCell else { return UITableViewHeaderFooterView() }
        let headerStrings = presenter.headingsForSection(section)
        cell.configure(headline: headerStrings.0, subheadline: headerStrings.1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SectionFooterCell(reuseIdentifier: "footer")
    }
}

class SectionFooterCell: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SectionHeaderCell: UITableViewHeaderFooterView {
    func configure(headline: String, subheadline: String) {
        label1.text = headline
        label2.text = subheadline
    }
    
    lazy var label1: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var label2: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.darkGray
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label1, label2])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        contentView.backgroundColor = UIColor.init(white: 0.93, alpha: 1)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class PicklistCell: UITableViewCell {
    
    func configureWithPicklist(_ picklist: PicklistProtocol) {
        label1.text = picklist.type.title.capitalizingFirstLetter()
        label2.text = picklist.itemSelectedSummary
    }
    
    lazy var label1: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var label2: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.lightGray
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label1, label2])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(horizontalStack)
        horizontalStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class PicklistDescriptionCell: UITableViewCell {
    
    func configureWithPicklist(_ picklist: PicklistProtocol) {
        label.text = picklist.type.userInstruction
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.darkGray
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.backgroundColor = UIColor.init(white: 0.93, alpha: 1)
        label.heightAnchor.constraint(lessThanOrEqualToConstant: 48).isActive = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.backgroundColor = label.backgroundColor
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
