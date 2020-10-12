
import WorkfinderCommon

class DeviceRegistrar: DeviceRegisteringProtocol {
    let log: F4SAnalyticsAndDebugging
    let environmentType: EnvironmentType
    let userRepository: UserRepositoryProtocol
    let session = URLSession.shared
    var authToken: String? { userRepository.loadAccessToken() }
    var identity: String? { userRepository.loadUser().uuid }
    
    var url: URL? {
        switch self.environmentType {

        case .develop:
            return URL(string: "https://develop.workfinder.com/v3/register-binding/")
        case .staging:
            return URL(string: "https://release.workfinder.com/v3/register-binding/")
        case .production:
            return URL(string: "https://workfinder.com/v3/register-binding/")
        }
        
    }
    
    init(userRepository: UserRepositoryProtocol,
         environmentType: EnvironmentType,
         log: F4SAnalyticsAndDebugging) {
        self.userRepository = userRepository
        self.environmentType = environmentType
        self.log = log
    }
    
    func registerDevice(token: Data) {
        guard let authToken = authToken, let identity = identity, let url = url else { return }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
        let params: [String: Any] = [
            "identity": identity,
            "binding_type" : "apn",
            "address" : tokenToString(token: token)
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { (responseData, response, error) in
            guard
                let responseData = responseData,
                let responseString = String(data: responseData, encoding: .utf8),
                let httpResponse = response as? HTTPURLResponse
                else {
                if let error = error {
                    print("Error registering for push notifications\n\(error)")
                }
                return
            }
            print(httpResponse.statusCode)
            print("Response Body: \(responseString)")
        }
        task.resume()
    }

}
