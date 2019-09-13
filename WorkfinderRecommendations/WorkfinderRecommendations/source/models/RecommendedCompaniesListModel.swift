import Foundation
import WorkfinderCommon
import WorkfinderServices

public protocol RecommendedCompaniesListModelProtocol : class {
    func fetch(completion: @escaping ([F4SRecommendation]?) -> Void)
}

/// Represents the list of companies we are currently recommending to the YP
public class RecommendedCompaniesListModel : RecommendedCompaniesListModelProtocol {
    
    let recommendationService: F4SRecommendationServiceProtocol
    
    public func fetch(completion: @escaping ([F4SRecommendation]?) -> ()) {
        recommendationService.fetch { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(var recommendations):
                    recommendations = recommendations.sorted() { return $0.index < $1.index }
                    completion(recommendations)
                case .error(_):
                    completion(nil)
                }
            }
        }
    }
    
    public init(recommendationsService: F4SRecommendationServiceProtocol = F4SRecommendationService()) {
        self.recommendationService = recommendationsService
    }
}
