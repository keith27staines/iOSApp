import UIKit
import WorkfinderUI

class F4SCalendarContainerViewController: UIViewController {
    @IBOutlet weak var pageHeaderView: F4SPageHeaderView!
    
    var delegate: F4SCalendarCollectionViewControllerDelegate?
    var maskView: UIView?
    
    lazy var infoController: F4SDisplayInformationViewController = {
        let storyboard = UIStoryboard(name: "F4SDisplayInformationViewController", bundle: __bundle)
        let vc = storyboard.instantiateInitialViewController() as! F4SDisplayInformationViewController
        vc.delegate = self
        vc.helpContext = F4SHelpContext.calendarController
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureControls()
        applyStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Availability"
        styleNavigationController()
    }

    override func viewDidAppear(_ animated: Bool) {
        if F4SHelpContext.calendarController.shouldShowAutomatically {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) { [weak self] in
                self?.mainInfoTapped()
            }
        }
    }
    
    var firstDate: Date?
    var lastDate: Date?
    
    func setSelection(firstDate: Date, lastDate: Date) {
        self.firstDate = firstDate
        self.lastDate = lastDate
    }
    
    func applyStyle() {
        pageHeaderView.splashColor = splashColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? F4SCalendarCollectionViewController else {
            return
        }
        if let firstDate = firstDate, let lastDate = lastDate {
            vc.setSelection(firstDate: firstDate, lastDate: lastDate)
        }
        vc.delegate = delegate
    }
}

// MARK:- Configure controls
extension F4SCalendarContainerViewController {
    func configureControls() {
        let item = UIBarButtonItem()
        item.title = ""
        item.image = UIImage(named: "information")
        item.target = self
        item.action = #selector(mainInfoTapped)
        item.style = .plain
        self.navigationItem.rightBarButtonItem = item
    }
}

// MARK:- Info view
extension F4SCalendarContainerViewController : F4SDisplayInformationViewControllerDelegate {
    
    func dismissDisplayInformation() {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
            self?.infoController.view?.alpha = 0.0
        }) { [weak self] (success) in
            self?.infoController.view?.removeFromSuperview()
            self?.maskView?.removeFromSuperview()
            self?.maskView = nil
        }
    }
    
    @objc func mainInfoTapped() {
        guard maskView == nil else { return }
        let mainView = self.view!
        let infoView = infoController.view!
        infoView.layer.borderColor = UIColor.darkGray.cgColor
        infoView.layer.borderWidth = 1
        infoView.layer.cornerRadius = 8
        infoView.clipsToBounds = true
        maskView = UIView(frame: mainView.frame)
        maskView?.translatesAutoresizingMaskIntoConstraints = false
        maskView?.isUserInteractionEnabled = true
        maskView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        mainView.addSubview(maskView!)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(infoView)
        maskView?.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        maskView?.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        maskView?.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        maskView?.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        if !self.children.contains(infoController) {
            self.addChild(infoController)
        }
        infoView.alpha = 0.0
        infoView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        infoView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        infoView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 40).isActive = true
        infoView.topAnchor.constraint(greaterThanOrEqualTo: mainView.topAnchor, constant: 60).isActive = true
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            infoView.alpha = 1.0
            mainView.layoutIfNeeded()
        }, completion: nil)
    }
}
