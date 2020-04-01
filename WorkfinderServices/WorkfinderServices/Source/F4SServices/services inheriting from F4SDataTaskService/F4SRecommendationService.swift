import Foundation
import WorkfinderCommon

public class F4SRecommendationService : F4SDataTaskService, F4SRecommendationServiceProtocol {
    public static let apiName = "recommend"
    public init(configuration: NetworkConfig) {
        super.init(baseURLString: configuration.workfinderApiV3, apiName: F4SRecommendationService.apiName, configuration: configuration)
    }

    public func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ()) {
        // beginGetRequest(attempting: "Get recommendations", completion: completion)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            completion(F4SNetworkResult.success([]))
        }
    }
}




