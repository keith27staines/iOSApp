
import UIKit
import WorkfinderUI

public protocol CoverLetterViewProtocol {
    var presenter: CoverLetterViewPresenterProtocol { get }
    func refresh(from presenter: CoverLetterViewPresenterProtocol)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class CoverLetterViewController: UIViewController, CoverLetterViewProtocol {
    
    let presenter: CoverLetterViewPresenterProtocol
    
    func refresh(from presenter: CoverLetterViewPresenterProtocol) {
        coverLetterTextView.attributedText = presenter.attributedDisplayString
        nextButton.isEnabled = presenter.nextButtonIsEnabled
        let color = presenter.nextButtonIsEnabled ? WorkfinderColors.primaryGreen : WorkfinderColors.lightGrey
        nextButton.setBackgroundColor(color: color, forUIControlState: .normal)
        editButton.configureForLetterIsCompleteState(presenter.nextButtonIsEnabled)
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
        view.backgroundColor = UIColor.white
        configureSubViews()
        configureNavigationController()
        presenter.onViewDidLoad(view: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.onDidTapShowCoverLetterButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent { presenter.onDidDismiss() }
    }

    @objc func onBackTapped() {
        presenter.onDidDismiss()
    }
    let userMessageHandler = UserMessageHandler()
    
    func showLoadingIndicator() {
        userMessageHandler.showLightLoadingOverlay(view)
    }
    
    func hideLoadingIndicator() {
        userMessageHandler.hideLoadingOverlay()
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
        configureNavigationController()
        configurePageStack()
    }
    
    func configureNavigationController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }
    
    func configurePageStack() {
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.pageStack)
        pageStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12).isActive = true
        pageStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true
        pageStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        pageStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12).isActive = true
    }
}

