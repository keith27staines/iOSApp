
import UIKit
import WorkfinderUI

public protocol CoverLetterViewProtocol {
    var messageHandler: UserMessageHandler { get }
    var presenter: CoverLetterViewPresenterProtocol { get }
    func refreshFromPresenter()
}

class CoverLetterViewController: UIViewController, CoverLetterViewProtocol {
    
    let presenter: CoverLetterViewPresenterProtocol
    
    func refreshFromPresenter() {
        coverLetterTextView.attributedText = presenter.attributedDisplayString
        nextButton.isEnabled = presenter.nextButtonIsEnabled
        let color = presenter.nextButtonIsEnabled ? WorkfinderColors.primaryColor : WorkfinderColors.lightGrey
        nextButton.setBackgroundColor(color: color, forUIControlState: .normal)
        editButton.configureForLetterIsCompleteState(presenter.nextButtonIsEnabled)
        nextButton.setTitle(presenter.primaryButtonTitle, for: .normal)
    }
    
    lazy var coverLetterTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapShowEditor)))
        return textView
    }()
    
    lazy var pageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.coverLetterTextView, self.nextButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var nextButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        return button
    }()
    
    lazy var editButton: EditApplicationLetterButton = {
        let button = EditApplicationLetterButton()
        button.addTarget(self, action: #selector(didTapShowEditor), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapShowTemplateButton() { presenter.onDidTapShowTemplateButton() }
    @objc func didTapShowCoverLetterButton() { presenter.onDidTapShowCoverLetterButton() }
    @objc func didTapShowEditor() { presenter.onDidTapSelectOptionsButton() }
    @objc func didCancel() { presenter.onDidDismiss() }
    @objc func didTapNext() { presenter.onDidTapNext() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Cover letter", comment: "")
        view.backgroundColor = UIColor.white
        configureSubViews()
        presenter.onViewDidLoad(view: self)
        refreshFromPresenter()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureNavigationBar()
        presenter.onDidTapShowCoverLetterButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent { presenter.onDidDismiss() }
    }
    
    func loadData() {
        showLoadingIndicator()
        presenter.loadData() { [weak self] optionalError in
            guard let self = self else { return }
            self.refreshFromPresenter()
            self.hideLoadingIndicator()
            self.messageHandler.displayOptionalErrorIfNotNil(
                optionalError,
                retryHandler: self.loadData)
        }
    }

    @objc func onBackTapped() {
        presenter.onDidDismiss()
    }
    lazy var messageHandler = UserMessageHandler(presenter: self)
    
    func showLoadingIndicator() {
        messageHandler.showLightLoadingOverlay(view)
    }
    
    func hideLoadingIndicator() {
        messageHandler.hideLoadingOverlay()
    }
    
    init(presenter: CoverLetterViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- configure subviews
extension CoverLetterViewController {
    func configureSubViews() {
        configurePageStack()
    }
    
    func configureNavigationBar() {
        navigationItem.backBarButtonItem?.title = "Back"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }
    
    func configurePageStack() {
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        view.addSubview(self.pageStack)
        pageStack.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 12).isActive = true
        pageStack.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -12).isActive = true
        pageStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12).isActive = true
        pageStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12).isActive = true
    }
}

