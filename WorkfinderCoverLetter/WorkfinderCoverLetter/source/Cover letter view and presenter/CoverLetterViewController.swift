
import UIKit
import WorkfinderUI
import WorkfinderCommon

protocol CoverLetterViewProtocol {
    var messageHandler: UserMessageHandler { get }
    var presenter: CoverLetterViewPresenterProtocol { get }
    func refreshFromPresenter()
}

class CoverLetterViewController: UIViewController, CoverLetterViewProtocol {
    
    let presenter: CoverLetterViewPresenterProtocol
    var showOverlay: Bool {
        get {
            return LocalStore().value(key: .showCoverLetterExplainer) as? Bool ?? true
        }
        set {
            LocalStore().setValue(false, for: .showCoverLetterExplainer)
        }
    }
    
    func refreshFromPresenter() {
        coverLetterTextView.attributedText = presenter.attributedDisplayString
        nextButton.isEnabled = presenter.isLetterComplete
        let color = presenter.isLetterComplete ? WorkfinderColors.primaryColor : WorkfinderColors.lightGrey
        nextButton.setBackgroundColor(color: color, forUIControlState: .normal)
        editButton.configureForLetterIsCompleteState(presenter.isLetterComplete)
        nextButton.setTitle(presenter.primaryButtonTitle, for: .normal)
    }
    
    lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.isUserInteractionEnabled = false
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0))
        label.numberOfLines = 0
        label.text = "Time to write your cover letter! We have given you a head start. To finish it, simply tap on the fields to edit them\n\nGo ahead, tap a field!"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        let top = label.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        top.priority = .defaultHigh
        top.isActive = true
        label.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -100).isActive = true
        return view
    }()
    
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
        guard let fieldName = fieldNameFromTapGesture(sender: sender)
        else {
            removeOverlay()
            return
        }
        showEditorForTappedFieldName(fieldName)
    }
    
    func showEditorForTappedFieldName(_ fieldName: String) {
        showLoadingIndicator()
        presenter.onDidTapField(name: fieldName) { [weak self] (optionalError) in
            self?.handleAsynchronousReturn(optionalError, retryHandler: nil)
        }
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
        messageHandler.displayOptionalErrorIfNotNil(
            presenter.fieldConsistencyError,
            cancelHandler: { [weak self] in
                self?.refreshFromPresenter()
                self?.hideLoadingIndicator()
            },
            retryHandler: nil
        )
        if !isLoading { hideLoadingIndicator() }
        if showOverlay { addOverlay() } else { removeOverlay() }
    }
    var isLoading = false
    func loadData() {
        isLoading = true
        showLoadingIndicator()
        presenter.loadData() { [weak self] optionalError in
            self?.handleAsynchronousReturn(optionalError, retryHandler: self?.loadData)
            self?.isLoading = false
        }
    }

    @objc func onBackTapped() { presenter.onDidCancel() }
    
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
    
    func addOverlay() {
        guard showOverlay else { return }
        view.addSubview(overlay)
        overlay.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        showOverlay = false
    }
    
    func removeOverlay() {
        UIView.animate(withDuration: 0.3, delay: 0, options: []) { [weak self] in
            self?.overlay.alpha = 0
        } completion: { [weak self] (_) in
            self?.overlay.removeFromSuperview()
        }
    }
    
    func configurePageStack() {
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        view.addSubview(self.pageStack)
        pageStack.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 12).isActive = true
        pageStack.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -12).isActive = true
        pageStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 26).isActive = true
        pageStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -12).isActive = true
    }
    
    func fieldNameFromTapGesture(sender: UITapGestureRecognizer) -> String? {
        var location = sender.location(in: coverLetterTextView)
        location.x -= coverLetterTextView.textContainerInset.left;
        location.y -= coverLetterTextView.textContainerInset.top;
        let characterIndex = coverLetterTextView.layoutManager.characterIndex(for: location, in: coverLetterTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard
            characterIndex < coverLetterTextView.textStorage.length,
            let fieldName = coverLetterTextView.attributedText?.attribute(NSAttributedString.Key.coverLetterField, at: characterIndex, effectiveRange: nil) as? String
        else {
           return nil
        }
        return fieldName
    }
    
    func handleAsynchronousReturn(_ optionalError: Error?, retryHandler: (()->Void)?) {
        refreshFromPresenter()
        hideLoadingIndicator()
        messageHandler.displayOptionalErrorIfNotNil(
            optionalError,
            retryHandler: retryHandler)
    }
}

