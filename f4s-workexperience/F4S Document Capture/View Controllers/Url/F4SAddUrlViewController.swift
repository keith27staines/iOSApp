//
//  AddUrlViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol F4SDCAddUrlViewControllerDelegate : class {
    func didCaptureUrl(_ url: URL)
}


class F4SAddUrlViewController: UIViewController {

    weak var delegate: F4SDCAddUrlViewControllerDelegate?
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let url = validURL else { return }
        delegate?.didCaptureUrl(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlField.delegate = self
        urlField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(handleCancel))
        cancelButton.tintColor = UIColor.blue
        navigationItem.rightBarButtonItem = cancelButton
        applySkin()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    @objc func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textChanged() {
        configure()
    }
    
    func applySkin() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: doneButton)
    }
    
    var validURL: URL? {
        guard let urlString = urlField.text, let url = URL(string: urlString) else { return nil }
        guard UIApplication.shared.canOpenURL(url) else { return nil }
        return url
    }
    
    func configure() {
        doneButton.isEnabled = validURL == nil ? false : true
    }
}

extension F4SAddUrlViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        configure()
        return true
    }
}




