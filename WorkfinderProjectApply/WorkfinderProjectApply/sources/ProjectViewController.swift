
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
        }
    }
    
    func refreshFromPresenter() {
        collectionView.reloadData()
        companyLogo.load(
            companyName: presenter.companyName ?? "",
            urlString: presenter.companyLogoUrl,
            completion: nil)
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
    
    lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        let frame = CGRect(x: 0, y: 0, width: 360, height: 100)
        let view = UICollectionView(frame: frame, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        view.dataSource = self
        view.delegate = self
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        registerCellsForReuse(view: view)
        return view
    }()
    
    func registerCellsForReuse(view: UICollectionView) {
        view.register(SectionHeadingCell.self, forCellWithReuseIdentifier: presenter.reuseIdentifierForSection(.aboutCompanySectionHeading))
        view.register(ProjectHeaderCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.projectHeader))
        view.register(ProjectBulletPointWithTitleCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.projectBulletPoints))
        view.register(AboutCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.aboutCompany))
        view.register(CapsuleCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.skillsYouWillGain))
        view.register(KeyActivityCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.keyActivities))
        view.register(AboutCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.aboutYou))
        view.register(ProjectContactCell.self,
                      forCellWithReuseIdentifier:presenter.reuseIdentifierForSection(ProjectPresenter.Section.projectContact))

    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(banner)
        view.addSubview(applyNowButton)
        view.addSubview(collectionView)
        view.addSubview(companyLogo)
        let guide = view.safeAreaLayoutGuide
        banner.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        collectionView.anchor(top: banner.bottomAnchor, leading: guide.leadingAnchor, bottom: applyNowButton.topAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        applyNowButton.anchor(top: nil, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        companyLogo.anchor(top: banner.bottomAnchor, leading: guide.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: -companyLogoSide/2, left: 20, bottom: 0, right: 0))
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
    
    init(coordinator: ProjectApplyCoordinator, presenter: ProjectPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ProjectViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cellPresenter = presenter.presenterForIndexPath(indexPath),
            let reuseIdentifier = presenter.reuseIdentifierForSection(indexPath.section),
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PresentableCellProtocol
            else {
            return UICollectionViewCell()
        }
        cell.parentWidth = collectionView.frame.width 
        cell.refreshFromPresenter(cellPresenter)
        let collectionViewCell = cell as! UICollectionViewCell
        collectionViewCell.layoutIfNeeded()
        return collectionViewCell
    }
}

extension ProjectViewController: UICollectionViewDelegate {
    
}

extension ProjectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
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
