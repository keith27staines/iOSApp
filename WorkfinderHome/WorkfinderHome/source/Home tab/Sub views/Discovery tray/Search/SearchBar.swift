
import UIKit
import WorkfinderUI

//class SearchBar: UISearchBar {
//
//    init() {
//        super.init(frame: CGRect.zero)
//        configureViews()
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    var textEntryField: UITextField? {
//        if #available(iOS 13.0, *) {
//            return searchTextField
//        } else {
//            return value(forKey: "searchField") as? UITextField
//        }
//    }
//
//    func configureViews() {
//        if let leftView = textEntryField?.leftView as? UIImageView {
//            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
//            leftView.tintColor = WorkfinderColors.primaryColor
//        }
//        autocapitalizationType = .none
//        autocorrectionType = .default
//        placeholder = "projects, companies, hosts"
//        returnKeyType = .search
//        enablesReturnKeyAutomatically = false
//        tintColor = WorkfinderColors.primaryColor
//    }
//}

protocol KSSearchBarDelegate: AnyObject {
    func searchbarTextDidChange(_ searchbar: KSSearchBar)
    func searchbarDidBeginEditing(_ searchbar: KSSearchBar)
    //func searchbarDidEndEditing(_ searchbar: KSSearchBar)
    func searchBarDidCancel(_ searchbar: KSSearchBar)
    func searchBarShouldReturn(_ searchbar: KSSearchBar) -> Bool
    func searchBarButtonTapped(_ searchbar: KSSearchBar)
}

class KSSearchBar: UIView {
    private let gap = CGFloat(20)
    private var capsuleContainerWidthConstraint: NSLayoutConstraint!
    private var cancelWidth: CGFloat { gap + cancelButton.frame.width }
    weak var delegate: KSSearchBarDelegate?
    
    private enum State {
        case inactive
        case activeEmpty
        case activeWithContent
    }
    
    private var state: State = .inactive {
        didSet { configureForState() }
    }
    
    override var tintColor: UIColor! {
        didSet {
            cancelButton.setTitleColor(tintColor, for: .normal)
            searchIcon.tintColor = tintColor
            clearButton.tintColor = tintColor
        }
    }
    
    var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    private lazy var searchIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.placeholder = "placeholder"
        view.delegate = self
        view.returnKeyType = .search
        view.autocorrectionType = .no
        view.autocapitalizationType = .none
        view.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return view
    }()
    
    private lazy var clearButton: UIView = {
        let view = UIImageView(image: UIImage(named: "circle_with_cross")?.withRenderingMode(.alwaysTemplate))
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clear)))
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.green, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    @objc private func clear() {
        guard clearButton.alpha > 0 else { return }
        textField.text = ""
        state = .activeEmpty
        delegate?.searchbarTextDidChange(self)
    }
    
    @objc private func cancel() {
        textField.resignFirstResponder()
        state = .inactive
        delegate?.searchBarDidCancel(self)
    }
    
    private lazy var capsuleStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(searchIcon)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(clearButton)
        stack.addArrangedSubview(cancelButton)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private lazy var capsuleContainer: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.backgroundColor = UIColor.init(white: 0.95, alpha: 1).cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        capsuleStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capsuleStack)
        NSLayoutConstraint.activate([
            capsuleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: gap),
            capsuleStack.topAnchor.constraint(equalTo: view.topAnchor),
            capsuleStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            capsuleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -gap),
            searchIcon.heightAnchor.constraint(equalTo: textField.heightAnchor, multiplier: 0.5),
            clearButton.heightAnchor.constraint(equalTo: textField.heightAnchor, multiplier: 0.5),
            searchIcon.widthAnchor.constraint(equalTo: searchIcon.heightAnchor),
            clearButton.widthAnchor.constraint(equalTo: clearButton.heightAnchor),
        ])
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        clipsToBounds = true
        addSubview(capsuleContainer)
        addSubview(cancelButton)
        capsuleContainer.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.sizeToFit()
        capsuleContainerWidthConstraint = capsuleContainer.widthAnchor.constraint(equalTo: widthAnchor, constant: -cancelWidth)
        NSLayoutConstraint.activate([
            capsuleContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            capsuleContainer.topAnchor.constraint(equalTo: topAnchor),
            capsuleContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: capsuleContainer.trailingAnchor, constant: gap),
            capsuleContainerWidthConstraint
        ])
        state = .inactive
        clearButton.alpha = 0
        cancelButton.isHidden = true
        configureForState()
    }
    
    private func configureForState() {
        switch state {
        case .inactive:
            animateOutClearButton()
            animateOutCancelButton()
        case .activeEmpty:
            animateOutClearButton()
            animateInCancelButton()
        case .activeWithContent:
            animateInClearButton()
            animateInCancelButton()
        }
    }
    
    private func animateOutClearButton() {
        let button = clearButton
        guard button.alpha > 0 else { return }
        UIView.animate(withDuration: 0.3) {
            button.alpha = 0
        }
    }
    
    private func animateInClearButton() {
        let button = clearButton
        guard button.alpha == 0 else { return }
        UIView.animate(withDuration: 0.3) {
            button.alpha = 1
        }
    }
    
    private func animateInCancelButton() {
        let button = cancelButton
        guard button.isHidden else { return }
        button.alpha = 0
        button.isHidden = false
        capsuleContainerWidthConstraint.constant = -cancelWidth
        UIView.animate(
            withDuration: 0.3) {
            button.alpha = 1
            self.layoutIfNeeded()
        } completion: { (finished) in
            
        }
    }
    
    private func animateOutCancelButton() {
        let button = cancelButton
        guard !button.isHidden else { return }
        capsuleContainerWidthConstraint.constant = 0
        UIView.animate(
            withDuration: 0.3) {
            button.alpha = 0
            self.layoutIfNeeded()
        } completion: { (finished) in
            button.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension KSSearchBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let count = textField.text?.count ?? 0
        state = count == 0 ? .activeEmpty : .activeWithContent
        delegate?.searchbarDidBeginEditing(self)
    }
    
    @objc func textFieldDidChange() {
        let count = textField.text?.count ?? 0
        state = count == 0 ? .activeEmpty : .activeWithContent
        delegate?.searchbarTextDidChange(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = delegate?.searchBarShouldReturn(self) ?? false
        if !shouldReturn {delegate?.searchBarButtonTapped(self)}
        return shouldReturn
        
    }
    
}
