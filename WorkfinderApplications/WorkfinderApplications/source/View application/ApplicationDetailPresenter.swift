import WorkfinderCommon

typealias ApplicationDetail = Application

protocol ApplicationDetailPresenterProtocol {
    var screenTitle: String { get }
    var stateDescription: String { get }
    func onViewDidLoad(completion: @escaping (Error?) -> Void)
}
class ApplicationDetailPresenter: ApplicationDetailPresenterProtocol{
    let service: ApplicationDetailServiceProtocol
    let coordinator: ApplicationsCoordinatorProtocol
    let application: Application
    var applicationDetail: ApplicationDetail?
    
    var screenTitle: String { application.state.screenTitle }
    var stateDescription: String { application.state.description }
    
    init(coordinator: ApplicationsCoordinatorProtocol,
         service: ApplicationDetailService,
         application: Application) {
        self.service = service
        self.coordinator = coordinator
        self.application = application
    }
    
    func onViewDidLoad(completion: @escaping (Error?) -> Void) {
        service.fetchApplicationDetail(application: application) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let applicationDetail):
                self.applicationDetail = applicationDetail
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
