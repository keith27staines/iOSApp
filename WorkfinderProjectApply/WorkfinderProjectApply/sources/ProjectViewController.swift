
import UIKit
import WorkfinderUI

protocol ProjectViewProtocol: AnyObject {
    func refreshFromPresenter()
}

class ProjectViewController: UIViewController, ProjectViewProtocol {
    
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    weak var coordinator: ProjectApplyCoordinatorProtocol?
    let presenter: ProjectPresenterProtocol
    
    lazy var applyNowButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Apply now!", for: .normal)
        button.addTarget(self, action: #selector(onTapApply), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        configureViews()
        presenter.onViewDidLoad(view: self)
        loadData()
    }
    
    func loadData() {
        self.refreshFromPresenter()
        messageHandler.showLoadingOverlay(self.view)
        presenter.loadData { [weak self] (optionalError) in
            guard let self = self else { return }
            self.messageHandler.hideLoadingOverlay()
            self.messageHandler.displayOptionalErrorIfNotNil(optionalError, cancelHandler: nil) {
                self.loadData()
            }
            self.refreshFromPresenter()
        }
    }
    
    func refreshFromPresenter() {
        projectDescription.text = presenter.projectDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        coordinator?.onFinished()
    }
    
    @objc func onTapApply() { coordinator?.onTapApply() }
    
    lazy var projectDescription: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(applyNowButton)
        let guide = view.safeAreaLayoutGuide
        applyNowButton.anchor(top: nil, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        view.addSubview(projectDescription)
        projectDescription.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: applyNowButton.topAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    init(coordinator: ProjectApplyCoordinator, presenter: ProjectPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
