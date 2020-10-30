
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol ProjectViewProtocol: AnyObject {
    func refreshFromPresenter()
}

class ProjectViewController: UIViewController, ProjectViewProtocol {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    weak var coordinator: ProjectApplyCoordinatorProtocol?
    let presenter: ProjectPresenterProtocol
    let companyLogoSide = CGFloat(80)
    
    var lastError: Error? {
        didSet {
            let title = lastError == nil ? "APPLY NOW" : "PLEASE SIGN IN"
            applyNowButton.setTitle(title, for: .normal)
        }
    }
    
    lazy var banner: UIImageView = {
        let image = UIImage(named: "projectPageBanner")
        let imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -20).isActive = true
        return imageView
    }()
    
    lazy var closeButton: ExpandedTouchButton = {
        let button = ExpandedTouchButton(type: .system)
        button.setImage(UIImage(named: "cross"), for: .normal)
        button.tintColor = UIColor.white
        button.imageView?.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    
    @objc func close() {
        coordinator?.onModalFinished()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    lazy var companyLogo: CompanyLogoView = {
        let imageView = CompanyLogoView(widthPoints: companyLogoSide, defaultLogoName: nil)
        imageView.heightAnchor.constraint(equalToConstant: companyLogoSide).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: companyLogoSide).isActive = true
        return imageView
    }()
    
    lazy var applyNowButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.addTarget(self, action: #selector(onTapApply), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        configureViews()
        lastError = nil
        presenter.onViewDidLoad(view: self)
        loadData()
    }
    
    func loadData() {
        self.refreshFromPresenter()
        self.lastError = nil
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self, let errorHandler = self.coordinator?.errorHandler else { return }
            self.lastError = optionalError
            errorHandler.startHandleError(
                optionalError,
                presentingViewController: self,
                messageHandler: self.messageHandler,
                cancel: {
                    self.refreshFromPresenter()
                    return
                },
                retry: {
                    self.loadData()
                }
            )
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        companyLogo.load(
            companyName: presenter.companyName ?? "",
            urlString: presenter.companyLogoUrl,
            completion: nil)
        applyNowButton.isEnabled = presenter.status == "open"
        showClosedForApplicationMessageIfNecessary(status: presenter.status)
    }
    
    func showClosedForApplicationMessageIfNecessary(status: String?) {
        guard let status = status, status != "open" else { return }
        let alert = UIAlertController(title: "Project \(status)" , message: "This project is not currently accepting applications", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func onTapApply() {
        if lastError != nil {
            loadData()
            return
        }
        coordinator?.onTapApply()
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = UIColor.white
        view.dataSource = self
        view.estimatedRowHeight = UITableView.automaticDimension
        view.rowHeight = UITableView.automaticDimension
        view.estimatedSectionHeaderHeight = UITableView.automaticDimension
        view.sectionHeaderHeight = UITableView.automaticDimension
        view.estimatedSectionFooterHeight = UITableView.automaticDimension
        view.sectionFooterHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.allowsSelection = false
        view.delegate = self
        registerCellsForReuse(view: view)
        return view
    }()
    
    func registerCellsForReuse(view: UITableView) {
        view.register(SectionHeadingCell.self, forCellReuseIdentifier: ProjectPresenter.Section.aboutCompanySectionHeading.reuseIdentifer)
        view.register(ProjectHeaderCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.projectHeader.reuseIdentifer)
        view.register(ProjectBulletPointWithTitleCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.projectBulletPoints.reuseIdentifer)
        view.register(AboutCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.aboutCompany.reuseIdentifer)
        view.register(CapsuleCollectionCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.skillsYouWillGain.reuseIdentifer)
        view.register(KeyActivityCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.keyActivities.reuseIdentifer)
        view.register(AboutCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.aboutYou.reuseIdentifer)
        view.register(ProjectContactCell.self,
                      forCellReuseIdentifier:ProjectPresenter.Section.projectContact.reuseIdentifer)
        view.register(ZeroHeightTableViewCell.self, forCellReuseIdentifier: presenter.reuseIdentifierForCollapsedRow)
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(banner)
        view.addSubview(applyNowButton)
        view.addSubview(tableView)
        view.addSubview(companyLogo)
        let guide = view.safeAreaLayoutGuide
        banner.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        tableView.anchor(top: banner.bottomAnchor, leading: guide.leadingAnchor, bottom: applyNowButton.topAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        applyNowButton.anchor(top: nil, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        companyLogo.anchor(top: banner.bottomAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: -companyLogoSide/2, left: 20, bottom: 0, right: 0))
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    init(coordinator: ProjectApplyCoordinator, presenter: ProjectPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ProjectViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cellPresenter = presenter.presenterForIndexPath(indexPath),
            let reuseIdentifier = presenter.reuseIdentifierForIndexPath(indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? PresentableCellProtocol
            else {
            return UITableViewCell()
        }
        cell.refreshFromPresenter(cellPresenter, width: tableView.frame.width)
        let tableViewCell = cell as! UITableViewCell
        tableViewCell.invalidateIntrinsicContentSize()
        return tableViewCell
    }
}

extension ProjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.isHiddenRow(indexPath: indexPath) ? 0 : UITableView.automaticDimension
    }
}

class ExpandedTouchButton: UIButton {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - 5.0,
            y: self.bounds.origin.y - 5.0,
            width: self.bounds.size.width + 10.0,
            height: self.bounds.size.height + 20.0
        )
        return newArea.contains(point)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
