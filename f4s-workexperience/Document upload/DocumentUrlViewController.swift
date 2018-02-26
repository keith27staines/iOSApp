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
    @IBOutlet var plusButtonCenterConstraint: NSLayoutConstraint!
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
        let maxUrls = documentUrlModel.maxUrls
        if documentUrlModel.numberOfRows(for: 0) == maxUrls {
            addAnother.text = "You cannot add more than \(maxUrls) links"
        }
    }
    
    @IBAction func showCVGuide(_ sender: Any) {
        let url = URL(string:"https://interactive.barclayslifeskills.com/staticmodules/downloads/cv-tips.pdf")!
        UIApplication.shared.openURL(url)
    }
    func updateEnabledStateOfAddButton() {
        let numberShown = documentUrlModel.numberOfRows(for: 0)
        if numberShown > 0 {
            if documentUrlModel.canAddLink() {
                addAnother.fadeTransition(0.4)
                addAnother.text = "Add another?"
                addAnother.alpha = 1
                let plusButton = self.plusButton!
                UIView.transition(with: plusButton,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: { plusButton.image = #imageLiteral(resourceName: "redPlusSmall") },
                                  completion: nil)
                
            } else {
                let plusButton = self.plusButton!
                UIView.transition(with: plusButton,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: { plusButton.image = #imageLiteral(resourceName: "greyPlus")},
                                  completion: nil)
                let maxUrls = documentUrlModel.maxUrls
                if numberShown >= maxUrls {
                    addAnother.fadeTransition(0.4)
                    addAnother.text = "You have added the maximum \(maxUrls) number allowed"
                } else {
                    addAnother.fadeTransition(0.4)
                    addAnother.text = "Tap below to paste your link"
                }
            }
        } else {
            transitionToBigPlusButton()
        }
    }
    
    func transitionToBigPlusButton() {
        guard isSetupForDisplayingUrls else { return }
        setupForCentralPlusButton()
        let containerView = self.containerView!
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            containerView.alpha = 0
        }) { (success) in
            containerView.isHidden = true
        }
    }
    
    @objc func transitionToDisplayUrls() {
        guard !isSetupForDisplayingUrls else { return }
        let view = self.view!
        let containerView = self.containerView!
        containerView.isHidden = false
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
extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}













