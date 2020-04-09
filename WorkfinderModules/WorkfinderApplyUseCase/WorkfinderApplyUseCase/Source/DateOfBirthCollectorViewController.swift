
import UIKit

protocol DateOfBirthCoordinatorProtocol: class {
    func onDidCancel()
    func onDidSelectDataOfBirth(date: Date)
}

class DateOfBirthCollectorViewController: UIViewController {
    
    weak var coordinator: DateOfBirthCoordinatorProtocol?
    
    var dateOfBirth: Date? {
        didSet {
            guard let dateOfBirth = dateOfBirth else {
                textField.text = nil
                nextButton.backgroundColor = UIColor.lightGray
                nextButton.isEnabled = false
                return
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            nextButton.isEnabled = true
            nextButton.backgroundColor = workfinderGreen
            self.textField.text = formatter.string(from: dateOfBirth)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        dateOfBirth = nil
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            coordinator?.onDidCancel()
        }
    }
    
    lazy var textField: UITextField = {
        let textfield = UITextField()
        view.addSubview(textfield)
        textfield.inputView = self.datePicker
        textfield.inputAccessoryView = self.toolbar
        textfield.placeholder = "Select date of birth"
        textfield.borderStyle = .roundedRect
        textfield.backgroundColor = UIColor.white
        return textfield
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Please set your date of birth", comment: "")
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(onDateChosen), for: .valueChanged)
        return datePicker
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toolbarDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        return toolBar
    }()
    
    @objc func toolbarDone() {
        updateStateFromPicker()
        view.endEditing(true)
    }
    
    @objc func nextButtonTapped() {
        coordinator?.onDidSelectDataOfBirth(date: datePicker.date)
    }
    
    func updateStateFromPicker() {
        self.dateOfBirth = datePicker.date
    }
    
    @objc func onDateChosen() { updateStateFromPicker() }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.label, self.textField, UIView(), self.nextButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 20).isActive = true
    }
    
    init(coordinator: DateOfBirthCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

