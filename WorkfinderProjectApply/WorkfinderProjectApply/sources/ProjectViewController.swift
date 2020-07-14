
import UIKit
import WorkfinderUI

class ProjectViewController: UIViewController {
    
    weak var coordinator: ProjectApplyCoordinator?
    let presenter: ProjectPresenter
    
    lazy var applyNowButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Apply now!", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        coordinator?.onFinished()
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(applyNowButton)
        let guide = view.safeAreaLayoutGuide
        applyNowButton.anchor(top: nil, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
    }
    
    init(coordinator: ProjectApplyCoordinator, presenter: ProjectPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
