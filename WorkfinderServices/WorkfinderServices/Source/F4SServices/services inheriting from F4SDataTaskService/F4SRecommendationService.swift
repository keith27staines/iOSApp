import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public class F4SRecommendationService : F4SDataTaskService, F4SRecommendationServiceProtocol {
    public static let apiName = "recommend"
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV2, apiName: F4SRecommendationService.apiName, configuration: configuration)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ()) {
        beginGetRequest(attempting: "Get recommendations", completion: completion)
    }
}




