import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public protocol F4SRecommendationServiceProtocol : class {
    func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ())
}

public class F4SRecommendationService : F4SDataTaskService, F4SRecommendationServiceProtocol {
    public static let apiName = "recommend"
    public init() {
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: F4SRecommendationService.apiName)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ()) {
        beginGetRequest(attempting: "Get recommendations", completion: completion)
    }
}




