//
//  F4SCompanyDocumentsContainerViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import Reachability

class F4SCompanyDocumentsContainerViewController: UIViewController {
    var overlay: UIView?
    
    var companyDocumentsModel: F4SCompanyDocumentsModel!
    var tableViewController: F4SCompanyDocumentsTableViewController!

    lazy var reachability: Reachability = {
        return Reachability()!
    }()
    
    var internetAvailable: Bool {
        return reachability.isReachableByAnyMeans
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyDocumentsModel = F4SCompanyDocumentsModel(companyUuid: "")
        tableViewController.companyDocumentModel = companyDocumentsModel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadDocumentsIfNecessary()
    }
    
    func loadDocumentsIfNecessary() {
        if companyDocumentsModel.documents != nil { return }
        guard internetAvailable else {
            MessageHandler.sharedInstance.display("No Internet Connection.", parentCtrl: self)
            return
        }
        MessageHandler.sharedInstance.showLightLoadingOverlay(self.view)
        companyDocumentsModel.loadDocuments { [weak self] (result) in
            self?.onDocumentsLoaded(result)
        }
    }
    
    func onDocumentsLoaded(_ result: F4SNetworkResult<CompanyDocuments>) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableViewController.tableView.reloadData()
            MessageHandler.sharedInstance.hideLoadingOverlay()
            
            switch result {
                
            case .error(_):
                return
            case .success(let documents):
                if documents.isEmpty {
                    strongSelf.showOverlayWithText(text: strongSelf.noDocumentsText)
                } else {
                    strongSelf.removeOverlay()
                }
                strongSelf.tableViewController.tableView.reloadData()
            }
        }
    }
    
    let noDocumentsText = NSLocalizedString("This company has not provided any documentation yet\n\nThis is where you can view important documents like safeguarding and insurance certificates", comment: "")

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedTableView" {
            guard let vc = segue.destination as? F4SCompanyDocumentsTableViewController else {
                return
            }
            tableViewController = vc
        }
    }
}

extension F4SCompanyDocumentsContainerViewController {
    
    func removeOverlay() {
        guard overlay == nil else { return }
        overlay?.removeFromSuperview()
        overlay = nil
    }
    
    func showOverlayWithText(text: String) {
        let overlay = showOverlay()
        addLabel(text, to: overlay)
    }
    
    @discardableResult func showOverlay() -> UIView? {
        removeOverlay()
        overlay = addMask()
        return overlay
    }
    
    func showOverlayWithError(error: F4SNetworkError, attempting: String, retryButton: Bool, retryAction: (()->())?) {
        let overlay = showOverlay()
        addLabel(error.localizedDescription, to: overlay)
    }
    
    func addMask() -> UIView? {
        guard let view = self.view else { return nil }
        let overlay = UIView()
        overlay.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 0.7)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        overlay.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        overlay.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return overlay
    }
    
    func addLabel(_ text: String, to mask: UIView?) {
        guard let mask = mask else { return }
        let overlayLabel = UILabel()
        overlayLabel.text = text
        overlayLabel.textColor = UIColor.white
        overlayLabel.numberOfLines = 0
        overlayLabel.lineBreakMode = .byWordWrapping
        overlayLabel.translatesAutoresizingMaskIntoConstraints = false
        mask.addSubview(overlayLabel)
        overlayLabel.frame = mask.frame
        overlayLabel.textColor = UIColor.white
        overlayLabel.isUserInteractionEnabled = true
        overlayLabel.leftAnchor.constraint(equalTo: mask.leftAnchor, constant: 50).isActive = true
        overlayLabel.rightAnchor.constraint(equalTo: mask.rightAnchor, constant: -50).isActive = true
        overlayLabel.topAnchor.constraint(equalTo: mask.topAnchor, constant: 50).isActive = true
        overlayLabel.bottomAnchor.constraint(equalTo: mask.bottomAnchor, constant: -50).isActive = true
    }
}
