//
//  PartnerSelectionViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit

class PartnerSelectionViewController: UIViewController {

    var isTableDropped: Bool = false
    var selectedPartner: F4SPartner? = nil
    
    @IBOutlet weak var instructionText: UILabel!
    
    @IBOutlet weak var referrerTextBox: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var partnerLogoRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var partnerLogoImageView: UIImageView!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        partnersModel.selectedPartner = selectedPartner
        dismiss(animated: true, completion: nil)
        CustomNavigationHelper.sharedInstance.navigateToMap()
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        loadPartersFromServer()
        tableHeightConstraint.constant = 0.0
        isTableDropped = false
        self.referrerTextBox.text = nil
        self.referrerTextBox.delegate = self
        self.doneButton.isEnabled = false
        self.partnerLogoRightConstraint.constant = -200
        self.applyStyle()
    }
    
    func loadPartersFromServer() {
        partnersModel.getPartnersFromServer { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                switch result {
                case .error(_):
                    self?.showNeedConnectionAlert()
                case .success(_):
                    break
                }
            }
        }
    }
    
    func showNeedConnectionAlert() {
        let title = NSLocalizedString("Workfinder needs an internet connection", comment: "")
        let message = NSLocalizedString("In order for us to set things up for you, please ensure that you have a good internet connection.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(
            title: NSLocalizedString("Retry", comment: ""),
            style: .default) { [weak self] (_) in
            self?.loadPartersFromServer()
        }
        alert.addAction(retryAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func applyStyle() {
        Skinner().apply(buttonSkin: skin?.primaryButtonSkin, to: doneButton)
        self.view.backgroundColor = RGBA.workfinderGreen.uiColor
    }
    
    lazy var partnersModel: F4SPartnersModel = {
        let model = F4SPartnersModel.sharedInstance
        return model
    }()
}

// MARK: UITextFieldDelegate conformance
extension PartnerSelectionViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !isTableDropped {
            animateDropDownTable(delay: 0.0)
            animatePartnerOut()
            doneButton.isEnabled = false
        } else {
            if let _ = selectedPartner {
                animatePullUpTable()
                animatePartnerIn()
                doneButton.isEnabled = true
            }
        }
        return false
    }
}

// MARK: UITableViewDatasource and delegate conformance
extension PartnerSelectionViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return partnersModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partnersModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "partnerCell")!
        let partner = partnersModel.partnerForIndexPath(indexPath)
        view.textLabel?.text = partner.name
        view.detailTextLabel?.text = partner.description
        //view.imageView?.image = partner.image
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPartner = partnersModel.partnerForIndexPath(indexPath)
        partnersModel.selectedPartner = selectedPartner
        referrerTextBox.text = selectedPartner?.name ?? ""
        partnerLogoImageView.image = selectedPartner?.image
        animatePullUpTable()
        
        if let _ = selectedPartner?.image {
            animatePartnerIn()
        }
    }
}

// MARK:- Helper functions
extension PartnerSelectionViewController {
    
    func rowHeight() -> CGFloat {
        let view = tableView.dequeueReusableCell(withIdentifier: "partnerCell")
        let height = view?.intrinsicContentSize.height ?? 50
        return height > 0 ? height : 50.0
    }
}

// MARK:- Animations
extension PartnerSelectionViewController {

    func animateDropDownTable(delay: Double) {
        if isTableDropped { return }
        isTableDropped = true
        UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.tableHeightConstraint.constant = strongSelf.rowHeight() * 5.5
            self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func animatePullUpTable() {
        if !isTableDropped { return }
        isTableDropped = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.tableHeightConstraint.constant = 0
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.doneButton.isEnabled = true
        })
    }
    
    func animatePartnerIn() {
    
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.partnerLogoRightConstraint.constant = 20
            self?.view.layoutIfNeeded()
        }
    }
    func animatePartnerOut() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.partnerLogoRightConstraint.constant = -200
            self?.view.layoutIfNeeded()
        }
    }
}
