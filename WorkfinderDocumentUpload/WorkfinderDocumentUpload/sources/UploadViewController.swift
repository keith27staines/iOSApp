
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
    
    lazy var actionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.init(white: 33/255, alpha: 1)
        return label
    }()
    
    lazy var adviceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 33/255, alpha: 1)
        return label
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
                    self.upload()
                }
            )
        }
    }
    
    func refresh() {
        progressView.fractionComplete = presenter.fractionComplete
        actionLabel.text = presenter.actionLabelText
        adviceLabel.text = presenter.adviceLabelText
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor.white
        view.addSubview(progressView)
        view.addSubview(actionLabel)
        view.addSubview(adviceLabel)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        adviceLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 150).isActive = true
        actionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        adviceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        actionLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 38).isActive = true
        adviceLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 38).isActive = true
        actionLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 27).isActive = true
        adviceLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -76).isActive = true
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
