
import UIKit
import WorkfinderCommon
import WorkfinderUI

protocol DateOfBirthCoordinatorProtocol: class {
    func onDidCancel()
    func onDidSelectDataOfBirth(date: Date)
}

class DateOfBirthCollectorViewController: UIViewController {
    
    weak var coordinator: DateOfBirthCoordinatorProtocol?
    
    let under13Text = "Thank you for using Workfinder. Unfortunately we can only accept candidates who are over 13 years old."
    
    lazy var icon: UIImageView = {
        
    }()
    
    lazy var underAgeWarning: UITextView = {
        let textView = UITextView()
        textView.alpha = 0
        textView.text = self.under13Text
        textView.font = WorkfinderFonts.body
        textView.textColor = WorkfinderColors.textMedium
        textView.dataDetectorTypes = .link
        textView.isEditable = false
        let height = textView.heightAnchor.constraint(equalToConstant: 200)
        height.priority = .defaultHigh
        height.isActive = true
        return textView
    }()
    
    var dateOfBirth: Date? {
        didSet {
            guard let dateOfBirth = dateOfBirth else {
                textField.text = nil
                setPrimaryButtonEnabledState(false)
                return
            }
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            textField.text = formatter.string(from: dateOfBirth)
            let age = ageNow(dob: dateOfBirth)
            let isOldEnough = age >= 13
            setPrimaryButtonEnabledState(isOldEnough)
            UIView.animate(withDuration: 0.3) {
                self.underAgeWarning.alpha = isOldEnough ? 0 : 1
            }
        }
    }
    
    func setPrimaryButtonEnabledState(_ enabled: Bool) {
        if enabled {
            nextButton.isEnabled = true
            nextButton.backgroundColor = WorkfinderColors.primaryColor
        } else {
            nextButton.backgroundColor = UIColor.lightGray
            nextButton.isEnabled = false
        }
    }
    
    func ageNow(dob: Date, now: Date = Date()) -> Int {
        return Calendar.current.dateComponents([.year], from: dob, to: now).year!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        dateOfBirth = nil
        textField.becomeFirstResponder()
        let now = Date()
        datePicker.date = Calendar.current.date(byAdding: .year, value: -18, to: now) ?? now
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -150, to: now) ?? now
        datePicker.maximumDate = now
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
        let button = WorkfinderPrimaryButton()
        button.setTitle("Next", for: .normal)
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
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
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
        let stack = UIStackView(arrangedSubviews: [
            self.label,
            self.textField,
            self.nextButton
            ]
        )
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    func configureNavigationBar() {
        title = "Date of Birth"
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(stack)
        view.addSubview(underAgeWarning)
        let guide = view.safeAreaLayoutGuide
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        underAgeWarning.anchor(top: stack.bottomAnchor, leading: stack.leadingAnchor, bottom: nil, trailing: stack.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        
    }
    
    init(coordinator: DateOfBirthCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

