
import WorkfinderCommon
import WorkfinderServices

class LoadingViewPresenter {
    weak var view: LoadingViewController?
    weak var coordinator: ViewRecommendationCoordinator?
    let recommendationUuid: F4SUUID
    let service: WorkplaceAndHostService
    
    func onViewDidLoad(_ view: LoadingViewController) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetchCompanyWorkplace(recommendationUuid: recommendationUuid) { result in
            switch result {
            case .success(let value):
                // leave screen spinning for a short time otherwise looks too transient
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) { [weak self] in
                    guard let self = self else { return }
                    completion(nil)
                    self.coordinator?.onWorkplaceAndHostObtainedFromRecommendation(value)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
        
    init(recommendationUuid: F4SUUID,
         service: WorkplaceAndHostService,
         coordinator: ViewRecommendationCoordinator) {
        self.recommendationUuid = recommendationUuid
        self.service = service
        self.coordinator = coordinator
    }
}
