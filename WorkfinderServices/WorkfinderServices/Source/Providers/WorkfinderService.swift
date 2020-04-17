
import Foundation
import WorkfinderCommon

public class WorkfinderService {
    public let networkConfig: NetworkConfig
    public var urlComponents: URLComponents
    public let taskHandler = DataTaskCompletionHandler()
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    var session: URLSession { networkConfig.sessionManager.interactiveSession }
    var task: URLSessionDataTask?
    
    public init(networkConfig: NetworkConfig) {
        self.networkConfig = networkConfig
        self.urlComponents = URLComponents(url: networkConfig.workfinderApiV3Url, resolvingAgainstBaseURL: true)!
    }
    
    public func deserialise<A:Decodable>(dataResult: Result<Data,Error>, completion: ((Result<A,Error>) -> Void)) {
        switch dataResult {
        case .success(let data):
            do {
                let json = try decoder.decode(A.self, from: data)
                completion(Result<A,Error>.success(json))
            } catch {
                completion(Result<A,Error>.failure(NetworkError.deserialization(error)))
            }
        case .failure(let error):
            completion(Result<A,Error>.failure(error))
        }
    }
}
