
import UIKit
import WorkfinderCommon
import WorkfinderUI

class OfferViewController: UIViewController {
    weak var coordinator: ApplicationsCoordinator?
    let presenter: OfferPresenterProtocol
    let messageHandler = UserMessageHandler()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.logo,
            self.messageLabel,
            self.tableView,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.heightAnchor.constraint(equalToConstant: 360).isActive = true
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(OfferDetailCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var logo: CompanyLogoView = {
        let logo = CompanyLogoView(widthPoints: 64)
        logo.heightAnchor.constraint(equalToConstant: 64).isActive = true
        return logo
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         presenter: OfferPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        configureViews()
        refreshFromPresenter()
    }
    
    func refreshFromPresenter() {
        messageHandler.showLoadingOverlay(view)
        presenter.load() { [weak self] (error) in
            guard let self = self else { return}
            self.messageHandler.hideLoadingOverlay()
            self.tableView.reloadData()
            self.messageLabel.text = self.presenter.stateDescription
            self.logo.load(
                urlString: self.presenter.logoUrl,
                defaultImage: nil,
                fetcher: nil,
                completion: nil)
            self.title = self.presenter.screenTitle
        }
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(mainStack)
        let guide = view.safeAreaLayoutGuide
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension OfferViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? OfferDetailCell else {
            return UITableViewCell()
        }
        let info = presenter.cellInfoForIndexPath(indexPath)
        cell.configure(info: info)
        return cell
    }
}

extension OfferViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Not available", message: "We are working on this. Please bear with us while we improve Workfinder", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

struct OfferDetailCellInfo {
    var firstLine: String?
    var secondLine: String?
}

class OfferDetailCell: UITableViewCell {
    lazy var firstLine: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    lazy var secondLine: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstLine, secondLine, UIView()])
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    func configure(info: OfferDetailCellInfo) {
        firstLine.text = info.firstLine
        secondLine.text = info.secondLine
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0))
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
