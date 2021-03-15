
import UIKit
import WorkfinderCommon
import WorkfinderUI

public protocol DateOfBirthCoordinatorProtocol: class {
    func onDidCancel()
    func onDidSelectDataOfBirth(date: Date)
}

public class DateOfBirthCollectorViewController: UIViewController {
    
    weak var coordinator: DateOfBirthCoordinatorProtocol?
    let minimumAge = 13
    
    var underageText: String { "Thank you for using Workfinder. Unfortunately we can only accept candidates who are over \(minimumAge) years old"}
    
    lazy var screenIcon: UIImageView = {
        let image = UIImage(named: "dob")
        let view = UIImageView(image: image)
        view.heightAnchor.constraint(equalToConstant: 81).isActive = true
        view.contentMode = .scaleAspectFit
        return view
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
            let isOldEnough = age >= minimumAge
            setPrimaryButtonEnabledState(isOldEnough)
            dateFieldStack.state = isOldEnough ? .good : .bad
            if !isOldEnough {
                let alert = UIAlertController(
                    title: "Under \(minimumAge)",
                    message: underageText,
                    preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
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

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        dateOfBirth = nil
        let now = Date()
        datePicker.date = Calendar.current.date(byAdding: .year, value: -18, to: now) ?? now
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -150, to: now) ?? now
        datePicker.maximumDate = now
        dateFieldStack.state = .bad
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        log?.track(.date_of_birth_capture_start)
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
//        if isMovingFromParent {
//            log?.track(.date_of_birth_capture_cancel)
//            coordinator?.onDidCancel()
//        }
    }
    
    lazy var dateFieldStack: UnderlinedNextResponderTextFieldStack = {
        let stack = UnderlinedNextResponderTextFieldStack(
            fieldName: "Select date of birth",
            goodUnderlineColor: WorkfinderColors.primaryColor,
            badUnderlineColor: WorkfinderColors.badValueNormal,
            state: .empty,
            nextResponderField: nil)
        let textField = stack.textfield
        textField.placeholder = "Tap here"
        textField.inputView = self.datePicker
        textField.font = WorkfinderFonts.body
        textField.inputAccessoryView = self.toolbar
        return stack
    }()
    
    var textField: UITextField { return dateFieldStack.textfield }
    
    lazy var nextButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.setTitle("Next", for: .normal)
        button.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = NSLocalizedString("Please enter your date of birth", comment: "")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var reasonLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("We tailor your application process\ndepending on your age", comment: "")
        label.numberOfLines = 0
        label.font = WorkfinderFonts.body2
        label.textAlignment = .center
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
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
        let dob = datePicker.date
        log?.track(.date_of_birth_capture_convert(dob))
        coordinator?.onDidSelectDataOfBirth(date: dob)
    }
    
    func updateStateFromPicker() {
        self.dateOfBirth = datePicker.date
    }
    
    @objc func onDateChosen() { updateStateFromPicker() }
    
    func configureNavigationBar() {
        title = "Date of Birth"
        navigationItem.hidesBackButton = true
    }
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(screenIcon)
        view.addSubview(headingLabel)
        view.addSubview(reasonLabel)
        view.addSubview(dateFieldStack)
        view.addSubview(nextButton)

        let guide = view.safeAreaLayoutGuide
        
        screenIcon.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        reasonLabel.translatesAutoresizingMaskIntoConstraints = false
        dateFieldStack.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        screenIcon.topAnchor.constraint(equalTo: guide.topAnchor, constant: 34).isActive = true
        headingLabel.topAnchor.constraint(equalTo: screenIcon.bottomAnchor, constant: 45).isActive = true
        reasonLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 10).isActive = true
        dateFieldStack.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 60).isActive = true
        nextButton.topAnchor.constraint(equalTo: dateFieldStack.bottomAnchor, constant: 41).isActive = true
        
        screenIcon.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        headingLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        reasonLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        dateFieldStack.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        
        screenIcon.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        headingLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        reasonLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 37).isActive = true
        dateFieldStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        nextButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        
    }
    
    weak var log: F4SAnalyticsAndDebugging?
    
    public init(coordinator: DateOfBirthCoordinatorProtocol, log: F4SAnalyticsAndDebugging) {
        self.coordinator = coordinator
        self.log = log
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

