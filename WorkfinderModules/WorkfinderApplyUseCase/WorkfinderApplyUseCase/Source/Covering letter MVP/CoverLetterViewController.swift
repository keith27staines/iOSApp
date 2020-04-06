
import UIKit

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
    }
    
    lazy var coverLetterTextView: UITextView = {
        let textView = UITextView()
        textView.text = "hello world"
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textAlignment = .left
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSelectOptionsButton)))
        return textView
    }()
    
    lazy var pageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.coverLetterTextView, self.nextButton])
        stack.axis = .vertical
        return stack
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 64).isActive = true
        button.setBackgroundColor(color: UIColor.lightGray, forUIControlState: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    lazy var editButton: EditApplicationLetterButton = {
        let button = EditApplicationLetterButton()
        button.addTarget(self, action: #selector(didTapSelectOptionsButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapShowTemplateButton() { presenter.onDidTapShowTemplateButton() }
    @objc func didTapShowCoverLetterButton() { presenter.onDidTapShowCoverLetterButton() }
    @objc func didTapSelectOptionsButton() { presenter.onDidTapSelectOptionsButton() }
    @objc func didCancel() { presenter.onDidDismiss() }
    
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
    
    func showLoadingIndicator() {
    }
    
    func hideLoadingIndicator() {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: EditApplicationLetterButton())
    }
    
    func configurePageStack() {
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.pageStack)
        pageStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 12).isActive = true
        pageStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12).isActive = true
        pageStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        pageStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 12).isActive = true
    }
}

