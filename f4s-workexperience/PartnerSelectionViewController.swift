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
    var selectedPartner: Partner? = nil
    
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
    }
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self

        tableHeightConstraint.constant = 0.0
        isTableDropped = false
        self.referrerTextBox.text = nil
        self.referrerTextBox.delegate = self
        self.doneButton.isEnabled = false
        self.partnerLogoRightConstraint.constant = -200
        let cerulean: UIColor = UIColor.init(red: 0.0/255.0, green: 160.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        let regalBlue = UIColor.init(red: 0.0/255.0, green: 68.0/255.0, blue: 113.0/255.0, alpha: 1.0)
        let ecstasy = UIColor.init(red: 244.0/255.0, green: 123.0/255.0, blue: 22.0/255.0, alpha: 1.0)
        let peach = UIColor.init(red: 255.0/255.0, green: 231.0/255.0, blue: 187.0/255.0, alpha: 1.0)
        let seagull = UIColor.init(red: 104.0/255.0, green: 199.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        let sail = UIColor.init(red: 207.0/255.0, green: 237.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        let backgroundColor: UIColor = cerulean
        let enabledButtonBackground = ecstasy
        let disabledButtonBackground = seagull
        let enabledButtonTextColor = UIColor.white
        let disabledButtonTextColor = sail
        
        self.view.backgroundColor = backgroundColor
        self.doneButton.setBackgroundColor(color: enabledButtonBackground, forUIControlState: .normal)
        self.doneButton.setBackgroundColor(color: disabledButtonBackground, forUIControlState: .disabled)
        self.doneButton.setTitleColor(enabledButtonTextColor, for: .normal)
        self.doneButton.setTitleColor(disabledButtonTextColor, for: .disabled)

    
    }
    
    lazy var partnersModel: PartnersModel = {
       return PartnersModel.sharedInstance
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
