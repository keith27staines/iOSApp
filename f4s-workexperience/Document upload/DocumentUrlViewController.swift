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
    }
    
    @IBAction func showCVGuide(_ sender: Any) {
        let url = URL(string:"https://interactive.barclayslifeskills.com/staticmodules/downloads/cv-tips.pdf")!
        UIApplication.shared.openURL(url)
    }
    func updateEnabledStateOfAddButton() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let numberShown = self.documentUrlModel.numberOfRows(for: 0)
            if numberShown > 0 {
                if self.documentUrlModel.doAllDescriptorsContainValidLinks() {
                    if self.documentUrlModel.canAddPlaceholder() {
                        self.transitionSmallPlusButton(toRed: true, text: "Add another")
                    } else {
                        let maxUrls = self.documentUrlModel.maxUrls
                        self.transitionSmallPlusButton(toRed: false, text: "You have added the maximum of \(maxUrls) links")
                    }
                } else {
                    self.transitionSmallPlusButton(toRed: false, text: "Tap below to paste your link")
                }
            } else {
                self.transitionToBigPlusButton()
            }
        }
    }
    
    func transitionSmallPlusButton(toRed: Bool, text:String) {
        self.addAnother.fadeTransition(0.4)
        self.addAnother.text = text
        guard let plusButton = self.plusButton else { return }
        let image = toRed ? #imageLiteral(resourceName: "redPlusSmall") : #imageLiteral(resourceName: "greyPlus")
        UIView.transition(with: plusButton,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { plusButton.image = image },
                          completion: nil)
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













