
import UIKit
import WorkfinderUI

class UploadViewController: UIViewController {
    weak var coordinator: DocumentUploadCoordinator?
    let presenter: UploadPresenter
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    lazy var progressView: WorkfinderProgressMeter = {
        let progress = WorkfinderControls.makeCircularProgressMeter()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.widthAnchor.constraint(equalTo: progress.heightAnchor, multiplier: 1).isActive = true
        progress.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return progress
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.onViewDidAppear(view: self)
        upload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.onViewWillDisappear()
    }
    
    func upload() {
        presenter.upload() { [weak self] error in
            guard let self = self else { return }
            self.messageHandler.displayOptionalErrorIfNotNil(
                error,
                cancelHandler: {
                    self.coordinator?.onUploadComplete()
                },
                retryHandler: {
                    
                }
            )
        }
    }
    
    func refresh() {
        progressView.fractionComplete = presenter.fractionComplete
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    init(coordinator: DocumentUploadCoordinator, presenter: UploadPresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
