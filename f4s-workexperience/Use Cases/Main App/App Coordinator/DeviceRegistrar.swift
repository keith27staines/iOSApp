
import WorkfinderCommon

class DeviceRegistrar: DeviceRegisteringProtocol {
    let url = URL(string: "https://develop.workfinder.com/v3/register-binding/")!
    let userRepository: UserRepositoryProtocol
    let session = URLSession.shared
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    var authToken: String? { userRepository.loadAccessToken() }
    
    func registerDevice(token: Data) {
        guard let authToken = authToken else { return }
        // Twilio-specific way of registering the device token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
        let params: [String: Any] = [
            "identity": userRepository.loadUser().uuid ?? "unknown user",
            "binding_type" : "apn",
            "address" : tokenToString(token: token)
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { [weak self] (responseData, response, error) in
            guard
                let responseData = responseData,
                let responseString = String(data: responseData, encoding: .utf8)
            else { return }
            
            print("Response Body: \(responseString)")
            do {
                let responseObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                print("JSON: \(responseObject)")
            } catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }

}
