
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
        self.urlComponents = URLComponents(
            url: networkConfig.workfinderApiV3Url,
            resolvingAgainstBaseURL: true)!
    }
    
    public func performTask<A:Decodable>(
        with request: URLRequest,
        verbose: Bool = false,
        completion: @escaping (Result<A,Error>) -> Void,
        attempting: String
    ) {
        task?.cancel()
        task = buildTask(
            request: request,
            completion: completion,
            attempting: attempting,
            verbose: verbose
        )
        task?.resume()
    }
    
    public func buildRequest<A: Encodable>(
        relativePath: String?,
        verb: RequestVerb, body: A,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        var request = try buildRequest(
            relativePath: relativePath,
            queryItems: queryItems,
            verb: verb)
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    public func buildRequest(
        relativePath: String?,
        queryItems: [URLQueryItem]?, verb: RequestVerb
    ) throws -> URLRequest {
        var components = urlComponents
        components.path += relativePath ?? ""
        components.queryItems = queryItems
        guard let url = components.url else {
            throw WorkfinderError(
                errorType: .invalidUrl(components.path),
                attempting: #function,
                retryHandler: nil) }
        return networkConfig.buildUrlRequest(url: url, verb: verb, body: nil)
    }
    
    public func buildRequest(
        path: String?,
        queryItems: [URLQueryItem]?, verb: RequestVerb
    ) throws -> URLRequest {
        let isAbsolute = (path ?? "").starts(with: "http")
        switch isAbsolute {
        case true: return try buildRequest(absolutePath: path, queryItems: queryItems, verb: .get)
        case false: return try buildRequest(relativePath: path, queryItems: queryItems, verb: .get)
        }
    }
    
    func buildRequest(
        absolutePath: String?,
        queryItems: [URLQueryItem]?, verb: RequestVerb
    ) throws -> URLRequest {
        guard var components = URLComponents(string: absolutePath ?? ""), let url = components.url else {
            throw WorkfinderError(
                errorType: .invalidUrl(absolutePath ?? ""),
                attempting: #function,
                retryHandler: nil) }
        components.queryItems = queryItems
        return networkConfig.buildUrlRequest(url: url, verb: verb, body: nil)
    }

    private func buildTask<ResponseJson:Decodable>(
        request: URLRequest,
        completion: @escaping ((Result<ResponseJson,Error>) -> Void),
        attempting: String,
        verbose: Bool
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.convertToDataResult(
                attempting: attempting,
                request: request,
                responseData: data,
                httpResponse: response as? HTTPURLResponse,
                error: error, verbose: verbose
            ) { [weak self] (result) in
                self?.deserialise(
                    dataResult: result,
                    verbose: verbose,
                    completion: completion)
            }
        })
        return task
    }
    
    private func deserialise<ResponseJson:Decodable>(
        dataResult: Result<Data,Error>,
        verbose: Bool,
        completion: ((Result<ResponseJson,Error>) -> Void)) {
        switch dataResult {
        case .success(let data):
            do {
                #if DEBUG
                captureJson(data: data, type: "\(ResponseJson.self)", verbose: verbose)
                #endif
                let json = try decoder.decode(ResponseJson.self, from: data)
                completion(Result<ResponseJson,Error>.success(json))
            } catch {
                let nsError = error as NSError
                let workfinderError = WorkfinderError(
                    errorType: .deserialization(error),
                    attempting: #function, retryHandler: nil)
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
    
    private func captureJson(data: Data?, type: String, verbose: Bool) {
        guard verbose else { return }
        print()
        print("--------------- Start Json capture --------------------")
        print("Deserialising \(type) from...")
        prettyPrint(data: data)
        print("--------------- End Json capture ----------------------")
        print()
    }
    
    private func prettyPrint(data: Data?) {
        guard let data = data else { return }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                let string = (String(bytes: prettyPrintedData, encoding: String.Encoding.utf8) ?? "")
                    .replacingOccurrences(of: "\\/", with: "/")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                print(string)
           }
        }
    }
}
