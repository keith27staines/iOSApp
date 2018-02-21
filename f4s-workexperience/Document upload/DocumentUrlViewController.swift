//
//  DocumentUrlViewController.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 15/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

class DocumentUrlViewController: UIViewController {
    var urlTableViewController: URLTableViewController?
    lazy var documentUrlModel: F4SDocumentUrlModel = {
        return F4SDocumentUrlModel(urlStrings: [], delegate: self)
    }()
    
    var user: User!
    var completion: ((User) -> Void)?
    
    @IBOutlet weak var topImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButtonCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var plusButton: UIImageView!
    
    @IBOutlet weak var plusButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var addAnother: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    var isSetupForDisplayingUrls: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addLinkButtonTapped))
        plusButton.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if documentUrlModel.numberOfRows(for: 0) > 0 {
            setupForDisplayingUrls()
        } else {
            setupForCentralPlusButton()
        }
        applyStyle()
    }
    
    func applyStyle() {
        F4SButtonStyler.apply(style: .primary, button: continueButton)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        completion?(user)
    }
    
    @objc func addLinkButtonTapped() {
        if !isSetupForDisplayingUrls {
            transitionToDisplayUrls()
        }
        urlTableViewController?.createNewLink()
    }
    
    func updateEnabledStateOfAddButton() {
        plusButton.image = documentUrlModel.canAddLink() ? #imageLiteral(resourceName: "redPlusSmall") : #imageLiteral(resourceName: "greyPlus")
        plusButton.sizeToFit()
    }
    
    @objc func transitionToDisplayUrls() {
        guard !isSetupForDisplayingUrls else { return }
        let view = self.view!
        let containerView = self.containerView!
        setupForDisplayingUrls()
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            view.layoutIfNeeded()
            containerView.alpha = 1.0
        }) { (success) in
            
        }
    }
    
    func setupForCentralPlusButton() {
        isSetupForDisplayingUrls = false
        plusButtonCenterConstraint.isActive = true
        plusButtonHeightConstraint.constant = 70
        plusButtonTopConstraint.constant = 40
        plusButton.image = #imageLiteral(resourceName: "redPlus") // standard size version
        plusButton.transform = CGAffineTransform.identity
        containerView.alpha = 0
        containerView.isHidden = true
        addAnother.alpha = 0.0
    }

    func setupForDisplayingUrls() {
        containerView.isHidden = false
        isSetupForDisplayingUrls = true
        plusButtonCenterConstraint.isActive = false
        plusButtonHeightConstraint.constant = 35
        plusButtonTopConstraint.constant = 10
        plusButton.image = documentUrlModel.numberOfRows(for: 0) < 3 ? #imageLiteral(resourceName: "redPlusSmall") : #imageLiteral(resourceName: "greyPlus")
        plusButton.transform = CGAffineTransform.identity
        containerView.frame = plusButton.frame
        addAnother.alpha = 1.0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedUrlDisplay" {
            urlTableViewController = (segue.destination as! URLTableViewController)
            urlTableViewController?.documentUrlModel = documentUrlModel
        }
    }
}

extension DocumentUrlViewController : F4SDocumentUrlModelDelegate {
    func documentUrlModel(_ model: F4SDocumentUrlModel, changedExpandedState: [IndexPath]) {
        
    }
    
    func documentUrlModel(_ model: F4SDocumentUrlModel, deleted: F4SDocumentUrlDescriptor) {
        updateEnabledStateOfAddButton()
    }
    func documentUrlModel(_ model: F4SDocumentUrlModel, updated: F4SDocumentUrlDescriptor) {
        updateEnabledStateOfAddButton()
    }
    func documentUrlModel(_ model: F4SDocumentUrlModel, created: F4SDocumentUrlDescriptor) {
        updateEnabledStateOfAddButton()
    }
}













