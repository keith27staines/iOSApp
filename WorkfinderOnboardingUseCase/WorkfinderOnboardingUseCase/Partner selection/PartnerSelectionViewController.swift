//
//  PartnerSelectionViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 26/10/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

class PartnerSelectionViewController: UIViewController {

    var isTableDropped: Bool = false
    var selectedPartner: F4SPartner? = nil
    
    @IBOutlet weak var partnerText: UILabel!
    @IBOutlet weak var instructionText: UILabel!
    
    @IBOutlet weak var referrerTextBox: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var partnerLogoRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var partnerLogoImageView: UIImageView!
    
    var doneButtonTapped: (() -> ())?
    var partnersModel: F4SPartnersModel!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        partnersModel.selectedPartner = selectedPartner
        doneButtonTapped?()
    }
    
    override func viewDidLoad() {
        self.applyStyle()
        tableView.dataSource = self
        tableView.delegate = self
        loadPartersFromServer()
        tableHeightConstraint.constant = 0.0
        isTableDropped = false
        self.referrerTextBox.text = nil
        self.referrerTextBox.delegate = self
        self.doneButton.isEnabled = false
        self.partnerLogoRightConstraint.constant = -200
        partnerText.isHidden = true
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return skin?.navigationBarSkin.statusbarMode == .light ? .lightContent : .default
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
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: doneButton)
        styleNavigationController()
        self.view.backgroundColor = splashColor
    }
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
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPartner = partnersModel.partnerForIndexPath(indexPath)
        partnersModel.selectedPartner = selectedPartner
        partnerText.isHidden = selectedPartner?.name.lowercased() == "ncs" ? false : true
        referrerTextBox.text = selectedPartner?.name ?? ""
        partnerLogoImageView.image = selectedPartner?.image
        animatePullUpTable()
        
        if let _ = selectedPartner?.image {
            animatePartnerIn()
        }
        applyStyle()
    }
}

// MARK:- Helper functions
extension PartnerSelectionViewController {
    
    func rowHeight() -> CGFloat {
        let view = tableView.dequeueReusableCell(withIdentifier: "partnerCell")
        let height = view?.intrinsicContentSize.height ?? 50
        return height > 0 ? height : 40.0
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
            let rows = CGFloat(self?.partnersModel.numberOfRowsInSection(0) ?? 0)
            strongSelf.tableHeightConstraint.constant = strongSelf.rowHeight() * rows
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
