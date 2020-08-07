
import UIKit
import WorkfinderUI

protocol AddFileViewControllerProtocol: class {
    func refresh()
}

class AddFileViewController: UIViewController, AddFileViewControllerProtocol {
    
    let presenter: AddFilePresenter
    var coordinator: DocumentUploadCoordinator?
    
    func refresh() {
        title = presenter.screenTitle
        heading.text = presenter.heading
        subheading1.text = presenter.subheading1
        subheading2.text = presenter.subheading2
        addFileButton.setTitle(presenter.state.addButtonTitle, for: .normal)
        primaryButton.setTitle(presenter.state.primaryButtonTitle, for: .normal)
        secondaryButton.setTitle(presenter.state.secondaryButtonTitle, for: .normal)
        addFileButton.isEnabled = presenter.state.addButtonIsEnabled
        primaryButton.isEnabled = presenter.state.primaryButtonIsEnabled
        secondaryButton.isEnabled = presenter.state.secondaryButtonIsEnabled
    }
    
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "")
        let imageView = UIImageView(image: image)
        imageView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 81).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor.init(white: 0.33, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    lazy var subheading1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 0.33, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var subheading2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 0.33, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var addFileButton: UIButton = {
        let button = WorkfinderControls.makeSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addFileTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var progressContainerView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    lazy var primaryButton: UIButton = {
        let button = WorkfinderControls.makePrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var secondaryButton: UIButton = {
        let button = WorkfinderControls.makeSecondaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var lowerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.addFileButton,
            self.progressContainerView,
            self.primaryButton,
            self.secondaryButton
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        return stack
    }()
    
    @objc func addFileTapped() {
        presenter.onAddTapped()
        let picker = UIDocumentPickerViewController(
            documentTypes: [
                "com.adobe.pdf",
                "com.microsoft.word.doc",
                "org.openxmlformats.wordprocessingml.document"
        ], in: .import)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func primaryTapped() { presenter.onPrimaryTapped() }
    
    @objc func secondaryTapped() { presenter.onSecondaryTapped() }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        configureViews()
        presenter.onViewDidLoad(view: self)
    }
    
    func configureViews() {
        let guide = view.safeAreaLayoutGuide
        view.addSubview(imageView)
        view.addSubview(heading)
        view.addSubview(subheading1)
        view.addSubview(subheading2)
        view.addSubview(lowerStack)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        heading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        heading.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 35).isActive = true
        subheading1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subheading1.leadingAnchor.constraint(equalTo: heading.leadingAnchor).isActive = true
        subheading2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subheading2.leadingAnchor.constraint(equalTo: subheading1.leadingAnchor, constant: 0).isActive = true
        lowerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 20).isActive = true
        heading.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        subheading1.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 10).isActive = true
        subheading2.topAnchor.constraint(equalTo: subheading1.bottomAnchor, constant: 20).isActive = true
        lowerStack.topAnchor.constraint(equalTo: subheading2.bottomAnchor, constant: 30).isActive = true
        lowerStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20).isActive = true
        lowerStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
    }
    
    init(coordinator: DocumentUploadCoordinator, presenter: AddFilePresenter) {
        self.coordinator = coordinator
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")
    }
    
}


extension AddFileViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            presenter.onAddCancelled()
            return
        }
        presenter.onFileSelected(fileUrl: url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        presenter.onAddCancelled()
    }
}
