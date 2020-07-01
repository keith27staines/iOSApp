
import WorkfinderCommon

class RecommendationsPresenter {
    
    let service: RecommendationsServiceProtocol
    var recommendations = [Recommendation]()
    
    init(service: RecommendationsServiceProtocol) {
        self.service = service
    }
    
    weak var view: RecommendationsViewController?
    
    func onViewDidLoad(view: RecommendationsViewController) {
        self.view = view
    }
    
    func loadData(completion: @escaping (Error?) -> Void) {
        service.fetchRecommendations(userUuid: "userUuid") { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let recommendations):
                self.recommendations = recommendations
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
