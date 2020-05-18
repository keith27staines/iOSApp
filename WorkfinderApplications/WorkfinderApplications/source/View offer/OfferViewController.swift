
import UIKit
import WorkfinderCommon
import WorkfinderUI

class OfferViewController: UIViewController, WorkfinderViewControllerProtocol {
    weak var coordinator: ApplicationsCoordinator?
    let presenter: OfferPresenterProtocol
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.logo,
            self.messageLabel,
            self.tableView,
            UIView(),
            self.acceptDeclineStack
        ])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    let declineButton = WorkfinderSecondaryButton()
    let acceptButton = WorkfinderPrimaryButton()
    
    lazy var acceptDeclineStack: UIStackView = {
        declineButton.addTarget(self, action: #selector(handleTapDecline), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(handleTapAccept), for: .touchUpInside)
        declineButton.setTitle(NSLocalizedString("Decline", comment: ""), for: .normal)
        acceptButton.setTitle(NSLocalizedString("Accept", comment: ""), for: .normal)
        let stack = UIStackView(arrangedSubviews: [declineButton,acceptButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    lazy var declineReasonsActionSheetFactory: DeclineReasonsActionSheetFactory  = {
        return DeclineReasonsActionSheetFactory { (reason) in
            self.handleDeclineWithReason(reason)
        }
    }()
    
    @objc func handleTapDecline() {
        let actionSheet = declineReasonsActionSheetFactory.makeDeclineOptionsAlert()
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func handleTapAccept() {
        messageHandler.showLoadingOverlay(self.view)
        presenter.onTapAccept { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.handleTapAccept()
            }
            self.refreshFromPresenter()
        }
    }
    
    func handleDeclineWithReason(_ reason: DeclineReason) {
        presenter.onTapDeclineWithReason(reason) { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError) {
                self.handleDeclineWithReason(reason)
            }
            self.refreshFromPresenter()
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
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
        presenter.onViewDidLoad(view: self)
        refreshFromPresenter()
        loadData()
    }
    
    func loadData() {
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData() { [weak self] (optionalError) in
            guard let self = self else { return}
            self.messageHandler.hideLoadingOverlay()
            self.refreshFromPresenter()
            self.messageHandler.displayOptionalErrorIfNotNil(
                optionalError,
                retryHandler: self.loadData)
        }
    }
    
    func refreshFromPresenter() {
        self.tableView.reloadData()
        self.messageLabel.text = self.presenter.stateDescription
        self.logo.load(
            urlString: self.presenter.logoUrl,
            defaultImage: nil,
            fetcher: nil,
            completion: nil)
        self.title = self.presenter.screenTitle
        acceptButton.isHidden = presenter.hideAcceptDeclineButtons
        declineButton.isHidden = presenter.hideAcceptDeclineButtons
    }
    
    @objc func share() {
        let snapshot = view.snapShot
        let items: [Any] = [
            "I have been offered a placement!",
            URL(string: "https://workfinder.com")!,
            snapshot
        ]
        let share = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    func configureViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
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
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    lazy var secondLine: UILabel = {
        let label = UILabel()
        label.font = WorkfinderFonts.heading
        label.textColor = UIColor.black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstLine, secondLine, UIView()])
        stack.spacing = 4
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
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

