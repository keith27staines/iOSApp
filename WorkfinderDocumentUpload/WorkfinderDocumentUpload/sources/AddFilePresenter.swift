
import WorkfinderCommon
import WorkfinderUI

protocol AddFilePresenterProtocol {
    func onViewDidLoad(view: AddFileViewControllerProtocol)
}

class AddFilePresenter: AddFilePresenterProtocol {
    
    var documentUploader = DocumentUploader()
    
    enum State {
        case noSelection
        case selecting
        case selectionGood
        case selectionTooBig
        case selectionWrongType
        case uploading(Int)
        case uploadSucceeded
        case uploadFailed

        var addButtonTitle: String { "SELECT DOCUMENT (10MB LIMIT)  +" }
        
        var primaryButtonTitle: String {
            switch self {
            case .uploadFailed: return "RETRY UPLOAD"
            default: return "UPLOAD"
            }
        }
        
        var secondaryButtonTitle: String { "SKIP" }
        
        var addButtonBorderColor: UIColor {
            switch self {
            case .selectionTooBig, .selectionWrongType, .uploadFailed: return .red
            default: return WorkfinderColors.primaryColor
            }
        }
        
        var errorText: String {
            switch self {
            case .selectionTooBig: return "The file is larger than 10MB, please select a smaller file."
            case .selectionWrongType: return "The file must be a PDF or a Word document.\nPlease choose again."
            case .uploadFailed: return "An error occurred. Please try again."
            default: return ""
            }
        }
        
        var addButtonIsEnabled: Bool {
            switch self {
            case .uploading(_):
                return false
            default:
                return true
            }
        }
        
        var primaryButtonIsEnabled: Bool {
            switch self {
            case .selectionGood, .uploadFailed: return true
            default: return false
            }
        }
        
        var secondaryButtonIsEnabled: Bool { true }
        
    }
    
    var coordinator: DocumentUploadCoordinator?
    var view: AddFileViewControllerProtocol?
    let screenTitle: String = "Supporting documents"
    let heading: String = "Stand out from the crowd!"
    let subheading1: String = "Add your CV or any supporting document to make it easier for companies to choose you."
    let subheading2: String = "We accept one PDF or Word document only"
    var errorText: String = ""
    var percentage: Int?
    
    var state: State = .noSelection {
        didSet {
            switch state {
            case .uploading(let percentage):
                self.percentage = percentage
            case .uploadSucceeded:
                self.percentage = 100
            default:
                self.percentage = 50
            }
            view?.refresh()
        }
    }
    
    init(coordinator: DocumentUploadCoordinator) {
        self.coordinator = coordinator
    }
    
    func onViewDidLoad(view: AddFileViewControllerProtocol) {
        self.view = view
        view.refresh()
    }
    
    func onAddTapped() {
        switch state {
        case .uploading, .uploadSucceeded:
            return
        default:
            state = .selecting
        }
    }
    
    func onPrimaryTapped() {
        switch state {
        case .selectionGood, .uploadFailed:
            documentUploader.uploadDocumentToURL(
                "url",
                progress: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let percentage):
                        self.state = .uploading(percentage)
                    case .failure(_):
                        self.state = .uploadFailed
                    }
                },
                completion: { (optionalError) in
                    if let _ = optionalError {
                        self.errorText = "An error has occurred. Please retry."
                    } else {
                        self.state = .uploadFailed
                    }
                }
            )
        default:
            return
        }
    }
    
    func onSecondaryTapped() {
        coordinator?.onSkip()
    }
    
    func onGoodFileSelected(fileUrl: String) {
        state = .selectionGood
    }
}
