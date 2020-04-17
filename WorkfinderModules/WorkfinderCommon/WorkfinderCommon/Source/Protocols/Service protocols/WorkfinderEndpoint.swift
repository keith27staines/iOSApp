import Foundation

/// `WorkfinderEndpoint defines the endpoint for the Workfinder api
public struct WorkfinderEndpoint {
    
    public let workfinderApiUrlString: String
    public let workfinderAPiUrl: URL
    
    public init(baseUrlString: String) throws {
        guard let url = URL(string: baseUrlString) else {
            throw WorkfinderCommonErrors.initialisedWithInvalidApiURLString(baseUrlString)
        }
        self.workfinderApiUrlString = baseUrlString
        self.workfinderAPiUrl = url
    }
}
