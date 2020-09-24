
import WorkfinderCommon

class DeviceRegistrar: DeviceRegisteringProtocol {
    let url = URL(string: "https://mahogany-clam-6213.twil.io/register-binding")!
    let userRepository: UserRepositoryProtocol
    let endpointKey = "TwilioEndpointKey"
    let session = URLSession.shared
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func registerDevice(token: Data) {
        // Twilio-specific way of registering the device token
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var params: [String: Any] = [
            "identity": userRepository.loadUser().uuid ?? "unknown user",
            "BindingType" : "apn",
            "Address" : tokenToString(token: token)
        ]
        
        //Check if we have an Endpoint identifier already for this app
        if let endpoint = UserDefaults.standard.string(forKey: endpointKey){
            params["endpoint"] = endpoint
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request) { [weak self] (responseData, response, error) in
            guard
                let self = self,
                let responseData = responseData,
                let responseString = String(data: responseData, encoding: .utf8)
            else { return }
            
            print("Response Body: \(responseString)")
            do {
                let responseObject = try JSONSerialization.jsonObject(with: responseData, options: [])
                print("JSON: \(responseObject)")
                if let responseDictionary = responseObject as? [String: Any] {
                    UserDefaults.standard.setValue(responseDictionary["identity"], forKey: self.endpointKey)
                    
                }
            } catch let error {
                print("Error: \(error)")
            }
        }
        task.resume()
    }

}
