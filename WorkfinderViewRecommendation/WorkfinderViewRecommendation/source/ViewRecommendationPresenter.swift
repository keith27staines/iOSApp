
import WorkfinderCommon
import WorkfinderServices

class LoadingViewPresenter {
    weak var view: LoadingViewController?
    weak var coordinator: RecommendedAssociationCoordinator?
    let recommendationUuid: F4SUUID
    let service: ApplicationContextService
    
    func onViewDidLoad(_ view: LoadingViewController) {
        self.view = view
    }
    
    func onCancel() {
        coordinator?.presenterDidCancel()
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetchStartingFrom(recommendationUuid: recommendationUuid) { result in
            switch result {
            case .success(let context):
                // leave screen spinning for a short time otherwise looks too transient
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) { [weak self] in
                    guard let self = self else { return }
                    completion(nil)
                    self.coordinator?.onApplicationContextObtainedFromRecommendation(context)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
        
    init(recommendationUuid: F4SUUID,
         service: ApplicationContextService,
         coordinator: RecommendedAssociationCoordinator) {
        self.recommendationUuid = recommendationUuid
        self.service = service
        self.coordinator = coordinator
    }
}
