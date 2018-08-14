//
//  RequestBLProvideDocuments.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class RequestBLProvideDocuments: UIViewController {
    var accept: AcceptOfferContext!
    var companyDocumentsModel: F4SCompanyDocumentsModel!

    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showVoucherEntry", sender: self)
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        MessageHandler.sharedInstance.showLoadingOverlay(self.view)
        companyDocumentsModel.requestDocumentsFromCompany { (result) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                MessageHandler.sharedInstance.hideLoadingOverlay()
                switch result {
                case .error(let error):
                    if error.retry {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: {
                            strongSelf.requestButtonTapped(sender)
                        })
                    } else {
                        MessageHandler.sharedInstance.display(error, parentCtrl: strongSelf, cancelHandler: nil, retryHandler: nil)
                    }
                case .success(_):
                    strongSelf.performSegue(withIdentifier: "showVoucherEntry", sender: strongSelf)
                }
            }
        }
    }
    
    var selectedDocument: F4SCompanyDocument? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyStyle()
        self.tableVIew.dataSource = self
        self.tableVIew.delegate = self
        configureButtons()
    }
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: skipButton)
        skinner.apply(buttonSkin: skin?.secondaryButtonSkin, to: skipButton)
    }

    func configureButtons() {
        requestButton.isEnabled = false
        for document in companyDocumentsModel.requestableDocuments {
            if document.userIsRequesting {
                requestButton.isEnabled = true
                break
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let enterVoucherViewController = segue.destination as? EnterVoucherViewController {
            enterVoucherViewController.accept = accept
            return
        }
        if let viewDocumentViewController = segue.destination as? ViewDocumentViewController, let documentToDisplay = selectedDocument {
            viewDocumentViewController.document = documentToDisplay
            return
        }
    }

}

extension RequestBLProvideDocuments : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return companyDocumentsModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return companyDocumentsModel.rowsInSection(section: section)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let document = companyDocumentsModel.document(indexPath) else {
            return UITableViewCell()
        }
        var cell: UITableViewCell? = nil
        switch document.state {
        case .available:
            if let aCell = tableVIew.dequeueReusableCell(withIdentifier: "viewCell") as? ViewTableViewCell {
                aCell.document = document
                cell = aCell
            }
        case .requested, .unrequested:
            if let aCell = tableVIew.dequeueReusableCell(withIdentifier: "switchCell") as? SwitchTableViewCell {
                aCell.document = document
                aCell.delegate = self
                cell = aCell
            }
        case .unavailable:
            break
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let document = companyDocumentsModel.document(indexPath) else {
            return
        }
        if document.state == .available {
            performSegue(withIdentifier: "showDocument", sender: self)
        }
    }
    
}

extension RequestBLProvideDocuments : SwitchTableViewCellDelegate {
    func switchCellDidSwitch(_ cell: SwitchTableViewCell, didSwitch on: Bool) {
        guard let document = cell.document else { return }
        _ = companyDocumentsModel.updateUserIsRequestingState(document: document, isRequesting: on)
        configureButtons()
    }
}







