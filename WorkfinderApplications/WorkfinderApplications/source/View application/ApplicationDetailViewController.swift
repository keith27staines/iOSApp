import UIKit
import WorkfinderCommon
import WorkfinderUI

class ApplicationDetailViewController: UIViewController, WorkfinderViewControllerProtocol {
    let presenter: ApplicationDetailPresenter
    lazy var messageHandler = UserMessageHandler(presenter: self)
    let appSource: AppSource
    let log: F4SAnalytics
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.addSubview(mainStack)
        mainStack.anchor(top: scroll.topAnchor, leading: scroll.leadingAnchor, bottom: scroll.bottomAnchor, trailing: scroll.trailingAnchor)
        mainStack.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        return scroll
    }()
    
    lazy var interviewOfferTile: OfferTile = {
        let offerTile = OfferTile()
        offerTile.heightAnchor.constraint(equalToConstant: 186).isActive = true
        return offerTile
    }()
    
    lazy var interviewInviteTile: InterviewInviteTile = {
        let tile = InterviewInviteTile()
        tile.heightAnchor.constraint(equalToConstant: 330).isActive = true
        return tile
    }()
    
    lazy var headerView = ApplicationDetailHeaderView()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = WFColorPalette.border
        return view
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headerView,
            separator,
            stateDescriptionLabel,
            interviewOfferTile,
            interviewInviteTile,
            //tableView,
            coverLetter
        ])
        stack.axis = .vertical
        stack.spacing = WFMetrics.standardSpace
        stack.distribution = .fill
        return stack
    }()
    
    lazy var coverLetter: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.applyStyle(WFTextStyle.bodyTextRegular)
        return text
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.setContentCompressionResistancePriority(.required, for: .vertical)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ApplicationDetailCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var stateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.borderWidth = 1
        label.layer.borderColor = WFColorPalette.border.cgColor
        label.heightAnchor.constraint(equalToConstant: 72).isActive = true
        return label
    }()
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         presenter: ApplicationDetailPresenter,
         appSource: AppSource,
         log: F4SAnalyticsAndDebugging
    ) {
        self.presenter = presenter
        self.appSource = appSource
        self.log = log
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        log.track(.application_page_view(appSource))
        configureNavigationBar()
        configureViews()
        presenter.onViewDidLoad(view: self)
        refreshFromPresenter()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent { log.track(.application_page_dismiss(appSource)) }
    }
    
    func loadData() {
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(
                optionalError,
                retryHandler: self.loadData
            )
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        messageHandler.hideLoadingOverlay()
        tableView.reloadData()
        stateDescriptionLabel.text = presenter.stateDescription
        coverLetter.text = presenter.coverLetterText
        stateDescriptionLabel.isHidden = presenter.statusLabelIsHidden
        interviewOfferTile.isHidden = presenter.interviewOfferTileIsHidden
        interviewInviteTile.isHidden = presenter.interviewInviteTileIsHidden
        interviewOfferTile.configure(with: presenter.interviewOfferData)
        interviewInviteTile.configure(with: presenter.interviewInviteData, offerMessageLines: 6)
        headerView.configureWith(presenter.headerData)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Application"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        styleNavigationController()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(scrollView)
        let guide = view.safeAreaLayoutGuide
        scrollView.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
//        tableView.heightAnchor.constraint(equalToConstant: 2 * 60).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ApplicationDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ApplicationDetailCell else {
            return UITableViewCell()
        }
        let info = presenter.cellInfoForIndexPath(indexPath)
        cell.configure(info: info)
        cell.accessoryType =  presenter.showDisclosureIndicatorForIndexPath(indexPath) ? .disclosureIndicator : .none
        return cell
    }
}

extension ApplicationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.onTapDetail(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

class ApplicationDetailCell: UITableViewCell {
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = WorkfinderFonts.heading
        label.textColor = UIColor.black
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
    }()
    lazy var subHeading: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = WorkfinderFonts.subHeading
        label.textColor = WorkfinderColors.textMedium
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.isUserInteractionEnabled = true
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [heading, subHeading])
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    func configure(info: ApplicationDetailCellInfo) {
        heading.text = info.heading
        subHeading.text = info.subheading
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
