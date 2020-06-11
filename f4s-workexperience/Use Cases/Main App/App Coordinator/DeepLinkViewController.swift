
import UIKit
import WorkfinderCommon
import WorkfinderUI

class DeepLinkViewController: UIViewController {
    
    let uuid: F4SUUID?
    
    lazy var label: UILabel = UILabel()
    
    init(uuid: F4SUUID?) {
        self.uuid = uuid
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        configureNavigationBar()
        label.addSubview(view)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.text = uuid ?? "No uuid to process"
    }
    
    func configureNavigationBar() {
        title = "DeepLink root"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
