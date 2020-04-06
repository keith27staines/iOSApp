
import UIKit

protocol LetterEditorCoordinatorProtocol: class {
    func start()
    func letterEditor(view: LetterEditorViewProtocol, updatedPickLists picklistsDictionary: PicklistsDictionary)
}

protocol LetterEditorViewProtocol: class {
    func refresh(_ presenter: LetterEditorPresenterProtocol)
}

class LetterEditorViewController: UIViewController, LetterEditorViewProtocol {

    let presenter: LetterEditorPresenterProtocol
    
    func refresh(_ presenter: LetterEditorPresenterProtocol) {
        
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(PicklistCell.self, forCellReuseIdentifier: "evencell")
        tableView.register(PicklistDescriptionCell.self, forCellReuseIdentifier: "oddcell")
        return tableView
    }()
    
    func configureViews() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureViews()
        tableView.dataSource = self
        tableView.delegate = self
        presenter.onViewDidLoad(view: self)
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
        return false
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
    
}

protocol LetterEditorPresenterProtocol {
    func onViewDidLoad(view: LetterEditorViewProtocol)
    func onDidDismiss()
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func picklist(for indexPath: IndexPath) -> Picklist
}

class LetterEditorPresenter: LetterEditorPresenterProtocol {
    
    func picklist(for indexPath: IndexPath) -> Picklist {
        let type = Picklist.PicklistType(rawValue: indexPath.row/2)!
        return picklistsDictionary[type]!
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int { return Picklist.PicklistType.allCases.count * 2 }
    func numberOfSections() -> Int { return 1 }
    
    weak var coordinator: LetterEditorCoordinatorProtocol?
    weak var view: LetterEditorViewProtocol?
    
    let picklistsDictionary: PicklistsDictionary = [
        .attributes: Picklist(type: .attributes),
        .roles: Picklist(type: .roles),
        .skills: Picklist(type: .skills),
        .universities: Picklist(type: .universities)
    ]
    
    func onViewDidLoad(view: LetterEditorViewProtocol) {
        self.view = view
        view.refresh(self)
        for (_, picklist) in picklistsDictionary {
            picklist.fetchItems { (picklist, result) in
                view.refresh(self)
            }
        }
    }
    
    func onDidDismiss() {
        guard let view = view else { return }
        coordinator?.letterEditor(view: view, updatedPickLists: picklistsDictionary)
    }
    
    init(coordinator: LetterEditorCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

class PicklistCell: UITableViewCell {
    
    func configureWithPicklist(_ picklist: Picklist) {
        label1.text = picklist.title.capitalizingFirstLetter()
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
    
    func configureWithPicklist(_ picklist: Picklist) {
        label.text = picklist.userInstruction
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.textColor = UIColor.darkGray
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.backgroundColor = UIColor.init(white: 0.93, alpha: 1)
        label.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
