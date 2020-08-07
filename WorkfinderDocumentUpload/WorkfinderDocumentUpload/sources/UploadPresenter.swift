
import WorkfinderCommon

class UploadPresenter {
    let filename: String
    let data: Data
    weak var view: UploadViewController?
    var fractionComplete: CGFloat = 0
    let uploader: DocumentUploader
    var error: Error?
    var coordinator: DocumentUploadCoordinator?
    
    init(coordinator: DocumentUploadCoordinator, filename: String, data: Data) {
        self.coordinator = coordinator
        self.filename = filename
        self.data = data
        self.uploader = DocumentUploader()
    }
    
    func onViewDidAppear(view: UploadViewController) {
        self.view = view
    }
    
    func onViewWillDisappear() {
        uploader.cancel()
    }
    
    func upload(errorHandler: @escaping (Error) -> Void) {
        uploader.uploadDocument(
            to: "",
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
