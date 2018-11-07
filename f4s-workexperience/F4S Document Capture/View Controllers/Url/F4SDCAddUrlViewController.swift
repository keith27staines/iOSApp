//
//  AddUrlViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SDCAddUrlViewControllerDelegate : class {
    func didCaptureUrl(_ url: URL)
}


class F4SDCAddUrlViewController: UIViewController {

    weak var delegate: F4SDCAddUrlViewControllerDelegate?
    
    @IBOutlet weak var urlField: UITextField!
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let url = URL(string: urlField.text ?? "") {
            delegate?.didCaptureUrl(url)
            performSegue(withIdentifier: "unwindToAddDocuments", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlField.delegate = self
    }
}

extension F4SDCAddUrlViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}




