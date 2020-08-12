
import WorkfinderCommon

class UploadPresenter {
    let filename: String
    let fileBytes: Data
    let metadata: [String: String]
    let urlString: String
    let method: RequestVerb
    weak var view: UploadViewController?
    var fractionComplete: CGFloat = 0
    let actionLabelText = "Uploading file"
    let adviceLabelText = "Please don’t close the app to avoid losing your upload and potentially your application"
    let uploader: DocumentUploader
    var error: Error?
    var coordinator: DocumentUploadCoordinator?
    
    init(
        coordinator: DocumentUploadCoordinator,
        filename: String,
        fileBytes: Data,
        metadata: [String:String],
        to urlString: String,
        method: RequestVerb,
        uploader: DocumentUploader) {
        self.coordinator = coordinator
        self.filename = filename
        self.fileBytes = fileBytes
        self.uploader = uploader
        self.metadata = metadata
        self.urlString = urlString
        self.method = method
    }
    
    func onViewDidAppear(view: UploadViewController) {
        self.view = view
    }
    
    func onViewWillDisappear() {
        uploader.cancel()
    }
    
    func upload(errorHandler: @escaping (Error) -> Void) {
        guard let url = URL(string: urlString) else {
            let error = WorkfinderError(errorType: .invalidUrl(urlString), attempting: "Upload document")
            errorHandler(error)
            return
        }
        uploader.upload(
            fileNamed: filename,
            fileBytes: fileBytes,
            metadata: metadata,
            to: url,
            method: method,
            progress: { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let fraction):
                    self.fractionComplete = CGFloat(fraction)
                    self.view?.refresh()
                case .failure(let error):
                    self.fractionComplete = 0
                    self.error = error
                    self.view?.refresh()
                    errorHandler(error)
                }
            },
            completion: { [weak self] optionalError in
                guard let self = self else { return }
                if let error = optionalError {
                    errorHandler(error)
                    self.fractionComplete = 0
                    self.view?.refresh()
                    return
                }
                self.coordinator?.onUploadComplete()
            }
        )
    }
    
    
    
    
}
