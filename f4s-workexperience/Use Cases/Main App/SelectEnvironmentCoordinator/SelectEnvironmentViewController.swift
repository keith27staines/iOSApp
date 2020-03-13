
import Foundation
import WorkfinderUI

class SelectEnvironmentViewController: UIViewController {
    var environments = [EnvironmentModel.makeStaging(), EnvironmentModel.makeCustom()]
    weak var coordinator: SelectEnvironmentCoordinating?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var urlAddressTextField: UITextField!
    @IBOutlet weak var testConnectionButton: UIButton!
    @IBOutlet weak var continueToWorkfinderButton: UIButton!
    let messageHandler = UserMessageHandler()
    
    @IBAction func testConnectionTap(_ sender: UIButton) {
        var model = selectedModel
        guard model.urlString != "https://workfinder.com" else {
            model.connectionState = .liveNotAllowed
            updateSelectedModel(model)
            presentSelectedEnvironment()
            showConnectedAlert()
            return
        }
        let urlString = model.urlString + "/api/v2/"
        guard let url = URL(string: urlString) else {
            model.connectionState = .badUrl
            updateSelectedModel(model)
            presentSelectedEnvironment()
            showConnectedAlert()
            return
        }
        let session = URLSession.shared
        
        messageHandler.showLoadingOverlay(view)
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.messageHandler.hideLoadingOverlay()
                if let error = error {
                    model.connectionState = .error(error)
                } else {
                    let code = (response as! HTTPURLResponse).statusCode
                    switch code {
                    case 404:
                        model.connectionState = .notFound
                    case 401:
                        model.connectionState = .connectable
                    default:
                        model.connectionState = .unexpectedStatus(code)
                    }
                }
                self.updateSelectedModel(model)
                self.presentSelectedEnvironment()
                self.showConnectedAlert()
            }
        })
        task.resume()
    }
    
    func showConnectedAlert() {
        let title: String
        let message: String
        switch selectedModel.connectionState {
        case .notTested:
            title = "Not tested"
            message = "Please test the connection"
        case .badUrl:
            title = "Bad URL"
            message = "Please correct the url or ip address"
        case .error(let error):
            title = "No connection"
            message = "Connection test failed:\n\(error.localizedDescription)"
        case .notFound:
            title = "API not found"
            message = "No api was found at the specified address"
        case .unexpectedStatus(let status):
            title = "No connection"
            message = "A \(status) response code was received from the server"
        case .liveNotAllowed:
            title = "Not permitted"
            message = "This version of the app is not permitted to connect to the Live environment"
        case .connectable:
            title = "Connected!"
            message = "It looks like you can connect to this environment"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func contineToWorkfinderTap(_ sender: UIButton) {
        coordinator?.userDidSelectEnvironment(environmentModel: selectedModel)
    }
    
    @IBAction func ipAddressChanged(_ sender: UITextField) {
        var model = selectedModel
        model.serverString = sender.text
        model.connectionState = .notTested
        updateSelectedModel(model)
        presentSelectedEnvironment()
    }
    
    var selectedModel: EnvironmentModel { return environments[segmentControl.selectedSegmentIndex] }
    
    func updateSelectedModel(_ model: EnvironmentModel) {
        environments[segmentControl.selectedSegmentIndex] = model
    }
    
    @IBAction func editingFinished(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        presentSelectedEnvironment()
    }
    
    override func viewDidLoad() {
        urlAddressTextField.delegate = self
        continueToWorkfinderButton.layer.cornerRadius = 8
        testConnectionButton.layer.cornerRadius = 8
        urlAddressTextField.placeholder = "hostname"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentSelectedEnvironment()
    }
    
    func presentSelectedEnvironment() {
        let model = selectedModel
        UIView.animate(withDuration: 0.2, animations: {
            self.urlAddressTextField.text = model.serverString
            self.continueToWorkfinderButton.alpha = model.canConnect ? 1 : 0.2
        }) { (finished) in
            self.urlAddressTextField.textColor = model.isEditable ? UIColor.darkText : UIColor.lightGray
            self.urlAddressTextField.isEnabled = model.isEditable
            self.continueToWorkfinderButton.isEnabled = model.canConnect ? true : false
        }
    }
}

extension SelectEnvironmentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

public struct EnvironmentModel {
    public enum EnvironmentDesignator {
        case custom
        case staging
        case production
    }
    
    public enum ConnectionState {
        case notTested
        case badUrl
        case error(Error)
        case notFound
        case unexpectedStatus(Int)
        case liveNotAllowed
        case connectable
    }
    
    public internal (set) var environment: EnvironmentDesignator
    public internal (set) var serverString: String?
    public internal (set) var isEditable: Bool = false
    public var connectionState: ConnectionState = .notTested
    
    public var canConnect: Bool {
        switch connectionState {
        case .connectable: return true
        default: return false
        }
    }
    
    public var urlString: String {
        return "https://" + (serverString ?? "")
    }
    
    static func makeStaging() -> EnvironmentModel {
        return EnvironmentModel(environment: .staging,
                                serverString: "staging.deprecated.workfinder.com",
                                isEditable: false,
                                connectionState: .connectable)
    }
    
    static func makeCustom() -> EnvironmentModel {
        return EnvironmentModel(environment: .custom,
                                serverString: "staging.workfinder.com",
                                isEditable: true,
                                connectionState: .notTested)
    }
}
