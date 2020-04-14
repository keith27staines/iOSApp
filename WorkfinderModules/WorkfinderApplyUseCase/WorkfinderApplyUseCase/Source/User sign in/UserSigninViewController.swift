
import UIKit
import WorkfinderUI

class UserSigninViewController: UIViewController {
    let presenter: UserSigninPresenterProtocol
    
    init(presenter: UserSigninPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var fullname: UnderlinedNextResponderTextField = {
        let fieldName = "full name"
        return self.makeTextView(fieldName: fieldName, nextResponder: self.nickname.textfield)
    }()
    lazy var nickname: UnderlinedNextResponderTextField = {
        let fieldName = "nickname"
        return self.makeTextView(fieldName: fieldName, nextResponder: self.email.textfield)
    }()
    
    lazy var email: UnderlinedNextResponderTextField = {
        let fieldName = "email"
        return self.makeTextView(fieldName: fieldName, nextResponder: self.password.textfield)
    }()
    
    lazy var password: UnderlinedNextResponderTextField = {
        let fieldName = "password"
        return self.makeTextView(fieldName: fieldName, nextResponder: self.button)
    }()
    
    lazy var fieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.fullname,
            self.nickname,
            self.email,
            self.password
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(fieldStack)
        fieldStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), size: CGSize.zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: UIControl.State.normal)
        button.isEnabled = false
        return button
    }()
    
    func makeTextView(fieldName: String,
                      nextResponder: UIResponder?) -> UnderlinedNextResponderTextField {
        let field =  UnderlinedNextResponderTextField(
            fieldName: fieldName,
            goodUnderlineColor: UIColor.blue,
            badUnderlineColor: UIColor.orange,
            state: .empty,
            nextResponderField: nextResponder)
        field.textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return field
    }
}
