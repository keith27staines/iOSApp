
import WorkfinderCommon

class RecommendationsPresenter {
    
    let service: RecommendationsServiceProtocol
    var recommendations = [Recommendation]()
    let userRepo: UserRepositoryProtocol
    
    init(service: RecommendationsServiceProtocol, userRepo:UserRepositoryProtocol) {
        self.service = service
        self.userRepo = userRepo
    }
    
    weak var view: RecommendationsViewController?
    
    var noRecommendationsYet: Bool {
        recommendations.count == 0 ? true : false
    }
    
    func onViewDidLoad(view: RecommendationsViewController) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        guard let _ = userRepo.loadAccessToken()
            else {
            completion(nil)
            return
        }
        service.fetchRecommendations(userUuid: "userUuid") { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let serverList):
                self.recommendations = serverList.results
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func numberOfSections() -> Int { 1 }
    func numberOfRowsForSection(_ section: Int) -> Int { recommendations.count }
    func recommendationForIndexPath(_ indexPath: IndexPath) -> Recommendation {
        return recommendations[indexPath.row]
    }
    
}
