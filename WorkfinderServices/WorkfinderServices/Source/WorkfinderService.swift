
import Foundation
import WorkfinderNetworking
import WorkfinderCommon

open class WorkfinderService {
    public let networkConfig: NetworkConfig
    public var urlComponents: URLComponents
    public let taskHandler = DataTaskCompletionHandler()
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    public var session: URLSession { networkConfig.sessionManager.interactiveSession }
    public var task: URLSessionDataTask?
    
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
                let nsError = error as NSError
                networkConfig.logger.logDeserializationError(
                    to: A.self,
                    from: data,
                    error: nsError)
                completion(Result<A,Error>.failure(NetworkError.deserialization(error)))
            }
        case .failure(let error):
            completion(Result<A,Error>.failure(error))
        }
    }
}
