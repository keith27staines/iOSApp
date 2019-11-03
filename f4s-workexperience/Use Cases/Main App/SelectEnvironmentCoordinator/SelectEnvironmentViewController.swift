
import Foundation

class SelectEnvironmentViewController: UIViewController {
    let environments = [EnvironmentModel.makeStaging(), EnvironmentModel.makeCustom()]
    weak var coordinator: SelectEnvironmentCoordinating?
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var testConnectionButton: UIButton!
    @IBOutlet weak var continueToWorkfinderButton: UIButton!
    
    @IBAction func testConnectionTap(_ sender: UIButton) {
    }
    
    @IBAction func contineToWorkfinderTap(_ sender: UIButton) {
        coordinator?.userDidSelectEnvironment()
    }
    
    @IBAction func ipAddressChanged(_ sender: UITextField) {
    }
    
    @IBAction func portChanged(_ sender: UITextField) {
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            presentEnvironment(environments[0])
        default:
            presentEnvironment(environments[1])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentEnvironment(environments[segmentControl.selectedSegmentIndex])
    }
    
    func presentEnvironment(_ model: EnvironmentModel) {

        UIView.animate(withDuration: 0.2, animations: {
            self.ipAddressTextField.text = model.ipAddress
            self.portTextField.text = model.port
            self.testConnectionButton.alpha = model.isEditable ? 1 : 0.2
            self.continueToWorkfinderButton.alpha = model.canConnect ? 1 : 0.2
        }) { (finished) in
            self.ipAddressTextField.isEnabled = model.isEditable
            self.portTextField.isEnabled = model.isEditable
            self.testConnectionButton.isEnabled = model.isEditable ? true : false
            self.continueToWorkfinderButton.isEnabled = model.canConnect ? true : false
        }
    }
}

struct EnvironmentModel {
    enum EnvironmentDesignator {
        case custom
        case staging
        case production
    }
    var environment: EnvironmentDesignator
    var ipAddress: String?
    var port: String?
    var canConnect: Bool = false
    var isEditable: Bool = false
    
    static func makeStaging() -> EnvironmentModel {
        return EnvironmentModel(environment: .staging, ipAddress: "staging.workfinder.com", port: "80", canConnect: true, isEditable: false)
    }
    
    static func makeCustom() -> EnvironmentModel {
        return EnvironmentModel(environment: .custom, ipAddress: "192.168.0.45", port: "8000", canConnect: false, isEditable: true)
    }
    
    static func makeProduction() -> EnvironmentModel {
        return EnvironmentModel(environment: .production, ipAddress: nil, port: nil, canConnect: false, isEditable: false)
    }
    
    
}
