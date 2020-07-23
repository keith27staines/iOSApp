
import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderCoordinators

protocol LetterEditorViewProtocol: class, UserMessageHandlingProtocol {
    func refresh()
}

class LetterEditorViewController: UIViewController {
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let presenter: LetterEditorPresenterProtocol
    
    func refresh() {
        presenter.onViewWillRefresh()
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
        tableView.separatorStyle = .singleLine
        tableView.register(PicklistCell.self, forCellReuseIdentifier: "picklistCell")
        tableView.register(SectionHeaderCell.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(SectionFooterCell.self, forHeaderFooterViewReuseIdentifier: "footer")
        tableView.sectionFooterHeight = UITableView.automaticDimension
        return tableView
    }()
    
    lazy var updateLetterButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Update letter", for: .normal)
        button.addTarget(self, action: #selector(onTapPrimaryButton), for: .touchUpInside)
        return button
    }()
    
    @objc func onTapPrimaryButton() {
        presenter.onTapPrimaryButton()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Edit Application"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
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
        configureNavigationBar()
        configureViews()
        tableView.dataSource = self
        tableView.delegate = self
        presenter.onViewDidLoad(view: self)
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
            self.refresh()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent { presenter.onDismiss() }
    }
    
    init(presenter: LetterEditorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension LetterEditorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let picklist = presenter.picklist(for: indexPath)
        presenter.showPicklist(picklist)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "picklistCell") as? PicklistCell else {
            return UITableViewCell()
        }
        let picklist = presenter.picklist(for: indexPath)
        cell.configureWithPicklist(picklist, index: indexPath.row + 1)
        let disclosureImage = UIImage(named: "disclosureIndicator")?.withRenderingMode(.alwaysTemplate)
        let disclosureImageView = UIImageView(image: disclosureImage)
        disclosureImageView.tintColor = WorkfinderColors.primaryColor
        cell.accessoryView = disclosureImageView
        return cell
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
        contentView.backgroundColor = UIColor.white
        let line = UIView()
        line.backgroundColor = UIColor.black
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentView.addSubview(line)
        line.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
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
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var label2: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label1, label2])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 12
        return stack
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        contentView.backgroundColor = UIColor.white
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 20, bottom: 4, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
