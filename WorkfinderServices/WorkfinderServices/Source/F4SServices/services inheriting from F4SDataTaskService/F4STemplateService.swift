import Foundation
import WorkfinderCommon

public class F4STemplateService:  F4SDataTaskService, F4STemplateServiceProtocol {
    
    public init(configuration: NetworkConfig) {
        let apiName = "cover-template"
        super.init(baseURLString: configuration.workfinderApiV2, apiName: apiName, configuration: configuration)
    }
    
    public func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void) {
        let attempting = "Get templates"
        beginGetRequest(attempting: attempting, completion: completion)
    }
}
