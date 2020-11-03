
import UIKit
import WorkfinderUI

protocol CoverLetterViewProtocol {
    var messageHandler: UserMessageHandler { get }
    var presenter: CoverLetterViewPresenterProtocol { get }
    func refreshFromPresenter()
}

class CoverLetterViewController: UIViewController, CoverLetterViewProtocol {
    
    let presenter: CoverLetterViewPresenterProtocol
    
    func refreshFromPresenter() {
        coverLetterTextView.attributedText = presenter.attributedDisplayString
        nextButton.isEnabled = presenter.isLetterComplete
        let color = presenter.isLetterComplete ? WorkfinderColors.primaryColor : WorkfinderColors.lightGrey
        nextButton.setBackgroundColor(color: color, forUIControlState: .normal)
        editButton.configureForLetterIsCompleteState(presenter.isLetterComplete)
        nextButton.setTitle(presenter.primaryButtonTitle, for: .normal)
    }
    
    lazy var coverLetterTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapShowEditor))
        textView.addGestureRecognizer(tapRecogniser)
        return textView
    }()
    
    lazy var pageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.coverLetterTextView, self.nextButton])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var nextButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        return button
    }()
    
    lazy var editButton: EditApplicationLetterButton = {
        let button = EditApplicationLetterButton()
        button.addTarget(self, action: #selector(didTapShowQuestionList), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapShowQuestionList() {
        presenter.onDidTapShowQuestionsList()
    }
    
    @objc func didTapShowEditor(sender: UITapGestureRecognizer) {
        // location of tap in coverLetterTextView coordinates taking the inset into account
        var location = sender.location(in: coverLetterTextView)
        location.x -= coverLetterTextView.textContainerInset.left;
        location.y -= coverLetterTextView.textContainerInset.top;
        
        // character index at tap location
        let layoutManager = coverLetterTextView.layoutManager
        let characterIndex = layoutManager.characterIndex(for: location, in: coverLetterTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        guard characterIndex < coverLetterTextView.textStorage.length,
              let fieldName = coverLetterTextView.attributedText?.attribute(NSAttributedString.Key.coverLetterField, at: characterIndex, effectiveRange: nil) as? String
        else {
            presenter.onDidTapShowQuestionsList()
            return
        }
        presenter.onDidTapField(name: fieldName)
    }
    
    @objc func didCancel() { presenter.onDidCancel() }
    @objc func didTapPrimaryButton() {
        messageHandler.showLightLoadingOverlay(view)
        presenter.onDidTapPrimaryButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureNavigationBar()
        configureSubViews()
        presenter.onViewDidLoad(view: self)
        loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent { presenter.onDidCancel() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.onViewDidAppear()
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
        presenter.onDidCancel()
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

extension CoverLetterViewController {
    func configureSubViews() {
        configurePageStack()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Cover Letter"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        styleNavigationController()
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
