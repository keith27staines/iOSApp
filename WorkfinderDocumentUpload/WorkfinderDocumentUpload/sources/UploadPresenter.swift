
import WorkfinderCommon

class UploadPresenter {
    weak var view: UploadViewController?
    var fractionComplete: CGFloat = 0
    let actionLabelText = "Uploading file"
    let adviceLabelText = "Please don’t close the app to avoid losing your upload and potentially your application"
    let uploader: DocumentUploaderProtocol
    var error: Error?
    var coordinator: DocumentUploadCoordinator?
    
    init(coordinator: DocumentUploadCoordinator,
         uploader: DocumentUploaderProtocol) {
        self.coordinator = coordinator
        self.uploader = uploader
    }
    
    func onViewDidAppear(view: UploadViewController) {
        self.view = view
    }
    
    func onViewWillDisappear() {
        uploader.cancel()
    }
    
    func upload(errorHandler: @escaping (Error) -> Void) {
        uploader.upload(
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
