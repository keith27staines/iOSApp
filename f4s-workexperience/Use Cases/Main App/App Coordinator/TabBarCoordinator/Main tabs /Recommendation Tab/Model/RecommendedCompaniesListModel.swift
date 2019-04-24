import Foundation

public protocol RecommendedCompaniesListModelProtocol : class {
    func fetch(completion: @escaping ([Recommendation]?) -> Void)
}

/// Represents the list of companies we are currently recommending to the YP
public class RecommendedCompaniesListModel : RecommendedCompaniesListModelProtocol {
    
    let recommendationService: F4SRecommendationServiceProtocol
    
    public func fetch(completion: @escaping ([Recommendation]?) -> ()) {
        recommendationService.fetch { (result) in
            switch result {
            case .success(var recommendations):
                recommendations = recommendations.sorted() { return $0.index < $1.index }
                DispatchQueue.main.async {
                    completion(recommendations)
                }
            case .error(let error):
                DispatchQueue.main.async {
                    globalLog.debug("error refreshing recommendations \n\(error)")
                    completion(nil)
                }
            }
        }
    }
    
    public init(recommendationsService: F4SRecommendationServiceProtocol = F4SRecommendationService()) {
        self.recommendationService = recommendationsService
    }
}

public protocol RecommendationProtocol {
    /// Required sort index
    var index: Int { get }
    /// the company uuid
    var uuid: F4SUUID? { get }
}

public struct Recommendation : Codable , Hashable, Equatable, RecommendationProtocol {
    public static func == (lhs: Recommendation, rhs: Recommendation) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    /// Required sort index
    public let index: Int
    /// the company uuid
    public let uuid: F4SUUID?
    
    public init(companyUUID: F4SUUID, sortIndex: Int) {
        self.index = sortIndex
        self.uuid = companyUUID.dehyphenated
    }
    
    public init(recommendation: RecommendationProtocol) {
        self.index = recommendation.index
        self.uuid = recommendation.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid ?? "")
    }
}
