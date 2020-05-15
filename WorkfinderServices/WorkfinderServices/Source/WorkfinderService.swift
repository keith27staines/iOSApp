
import Foundation
import WorkfinderNetworking
import WorkfinderCommon

open class WorkfinderService {
    public let networkConfig: NetworkConfig
    
    private var urlComponents: URLComponents
    private let taskHandler: DataTaskCompletionHandler
    private var session: URLSession { networkConfig.sessionManager.interactiveSession }
    private var task: URLSessionDataTask?
    lazy private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    lazy private var encoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    public init(networkConfig: NetworkConfig) {
        self.networkConfig = networkConfig
        self.taskHandler = DataTaskCompletionHandler(logger: networkConfig.logger)
        self.urlComponents = URLComponents(url: networkConfig.workfinderApiV3Url, resolvingAgainstBaseURL: true)!
    }
    
    public func performTask<A:Decodable>(
        with request: URLRequest,
        completion: @escaping (Result<A,Error>) -> Void,
        attempting: String) {
        task?.cancel()
        task = buildTask(
            request: request,
            completion: completion,
            attempting: attempting)
        task?.resume()
    }
    
    public func buildRequest<A: Encodable>(relativePath: String?, verb: RequestVerb, body: A) throws -> URLRequest {
        var request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: verb)
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    public func buildRequest(relativePath: String?, queryItems: [URLQueryItem]?, verb: RequestVerb) throws -> URLRequest {
        var components = urlComponents
        components.path += relativePath ?? ""
        components.queryItems = queryItems
        guard let url = components.url else { throw WorkfinderError(errorType: .invalidUrl(components.path), attempting: #function, retryHandler: nil) }
        return networkConfig.buildUrlRequest(url: url, verb: verb, body: nil)
    }

    private func buildTask<ResponseJson:Decodable>(
        request: URLRequest,
        completion: @escaping ((Result<ResponseJson,Error>) -> Void),
        attempting: String) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self, let httpResponse = response as? HTTPURLResponse else { return }
            self.taskHandler.convertToDataResult(
                attempting: attempting,
                request: request,
                responseData: data,
                httpResponse: httpResponse,
                error: error) { [weak self] (result) in
                    self?.deserialise(dataResult: result, completion: completion)
                
            }
        })
        return task
    }
    
    private func deserialise<ResponseJson:Decodable>(dataResult: Result<Data,Error>, completion: ((Result<ResponseJson,Error>) -> Void)) {
        switch dataResult {
        case .success(let data):
            do {
                let json = try decoder.decode(ResponseJson.self, from: data)
                completion(Result<ResponseJson,Error>.success(json))
            } catch {
                let nsError = error as NSError
                let workfinderError = WorkfinderError(errorType: .deserialization(error), attempting: #function, retryHandler: nil)
                networkConfig.logger.logDeserializationError(
                    to: ResponseJson.self,
                    from: data,
                    error: nsError)
                completion(Result<ResponseJson,Error>.failure(workfinderError))
            }
        case .failure(let error):
            completion(Result<ResponseJson,Error>.failure(error))
        }
    }
}
