
import WorkfinderCommon
import WorkfinderUI

protocol AddFilePresenterProtocol {
    func onViewDidLoad(view: AddFileViewControllerProtocol)
}

class AddFilePresenter: AddFilePresenterProtocol {
    var log: F4SAnalyticsAndDebugging? { coordinator?.injected.log}
    var uploadBytes: Data?
    var filename: String?
    var mime: String?
    let maxBytes = 10 * 1024 * 1024
    
    enum State {
        case noSelection
        case selecting
        case selectionGood
        case selectionTooBig
        case selectionWrongType
        case uploading(Float)
        case uploadSucceeded
        case uploadFailed

        var addButtonTitle: String { "SELECT DOCUMENT (10MB LIMIT)  +" }
        
        var primaryButtonTitle: String {
            switch self {
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
            case .selectionTooBig: return "The file is larger than 10MB. Please select a smaller file."
            case .selectionWrongType: return "Please choose a PDF or a Word document"
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
    let subheading1: String = "Applications that have a supporting CV or portfolio attached are much more likely to receive an offer."
    let subheading2: String = "We accept one PDF or Word document only"
    var fractionComplete: Float?
    
    var state: State = .noSelection {
        didSet {
            switch state {
            case .uploading(let fractionComplete):
                self.fractionComplete = fractionComplete
            case .uploadSucceeded:
                self.fractionComplete = 1
            case .selectionGood:
                log?.track(.document_upload_document_selected)
                self.fractionComplete = 0
            default:
                self.fractionComplete = 0
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
    
    func onAddCancelled() {
        state = .noSelection
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
            guard let filename = filename, let data = uploadBytes, let mime = mime else { return }
            coordinator?.upload(
                filename: filename,
                data: data, mime: mime,
                metadata: [:]
            )
        default:
            return
        }
    }
    
    func onSecondaryTapped() {
        coordinator?.onSkip()
    }
    
    func onFileSelected(fileUrl: URL) {
        do {
            filename = fileUrl.lastPathComponent
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            guard let mime = MimeType(fileExtension: fileUrl.pathExtension) else {
                state = .selectionWrongType
                return
            }
            guard data.count <= maxBytes else {
                state = .selectionTooBig
                return
            }
            uploadBytes = data
            self.mime = mime.rawValue
            state = .selectionGood
        } catch {
            state = .selectionWrongType
        }
    }
}
