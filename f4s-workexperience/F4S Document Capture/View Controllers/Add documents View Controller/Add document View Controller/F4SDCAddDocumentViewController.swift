//
//  ViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SDCAddDocumentViewControllerDelegate : class {
    func didAddDocument(_ document: F4SDocument, popIsRequired: Bool)
}

class F4SDCAddDocumentViewController: UIViewController {

    @IBOutlet weak var documentTypeIntroductionLabel: UILabel!
    
    @IBOutlet var addButtons: [UIButton]!
    
    @IBOutlet weak var dropDownHeightConstraint: NSLayoutConstraint!
    weak var delegate: F4SDCAddDocumentViewControllerDelegate?
    
    internal private (set) var popIsRequired: Bool = false
    
    var document: F4SDocument = F4SDocument(type: .other) {
        didSet {
            setStateForDocumentType(document.type)
        }
    }
    var userHasEditedName: Bool = false
    
    var documentTypes: [F4SUploadableDocumentType] = [F4SUploadableDocumentType]() {
        didSet {
            _ = view
            if documentTypes.count == 1 {
                documentTypeIntroductionLabel.text = "Add a document of type:"
                setStateForDocumentType(documentTypes.first!)
            } else {
                documentTypeIntroductionLabel.text = "What type of document will you add?"
            }
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        setAddButtonsEnabled(state: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyStyle()
    }
    
    func applyStyle() {
        let skinner = Skinner()
        addButtons.forEach { (button) in
            skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: button)
        }
    }
    
    lazy var imagePickerViewController: UIImagePickerController = {
        let pickerViewController = UIImagePickerController()
        pickerViewController.allowsEditing = false
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.delegate = self
        return pickerViewController
    }()
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showCamera", sender: self)
    }
    
    @IBAction func pickFromLibrary(_ sender: Any) {
        present(imagePickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func pickFromFilesystem(_ sender: Any) {
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    lazy var documentPicker: UIDocumentPickerViewController = {
        let documentTypes = ["public.text", "com.adobe.pdf", "com.microsoft.word.doc"]
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        return documentPicker
    }()
    
    var documentTypeSelector: F4SDCDocumentTypeViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        popIsRequired = true
        switch segue.identifier {
        case "showCamera":
            if let navigationController = segue.destination as? UINavigationController,
                let vc = navigationController.viewControllers.first as? F4SCameraPageManagerViewController
                {
                    vc.delegate = self
                    return
            }
        case "showURL":
            if let vc = segue.destination as? F4SDCAddUrlViewController {
                popIsRequired = false
                vc.delegate = self
            }
        case "embedDocumentTypePicker":
            if let vc = segue.destination as? F4SDCDocumentTypeViewController {
                vc.dropHeightConstraint = dropDownHeightConstraint
                vc.documentTypes = documentTypes
                vc.onSelected = { index in
                    let type = vc.documentTypes[index]
                    self.document.type = type
                    self.setStateForDocumentType(type)
                }
                documentTypeSelector = vc
            }
        default:
            break
        }
    }
    
    func setStateForDocumentType(_ type: F4SUploadableDocumentType) {
        document.type = type
        documentTypeSelector?.labelView.text = type.name
        updateDocumentName(type: type.name)
        setAddButtonsEnabled(state: true)
        nameField.becomeFirstResponder()
    }
    
    func updateDocumentName(type: String) {
        if !userHasEditedName {
            nameField.text = document.defaultName
        }
        document.name = nameField.text
    }
}

extension F4SDCAddDocumentViewController {
    func setAddButtonsEnabled(state: Bool) {
        addButtons.forEach { (button) in
            button.isEnabled = state
            button.backgroundColor = state == true ? UIColor.blue : UIColor.lightGray
        }
    }
}

extension F4SDCAddDocumentViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let name = textField.text ?? ""
        document.name = name
        if !name.isEmpty {
            setAddButtonsEnabled(state: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        userHasEditedName = true
        return true
    }
}

extension F4SDCAddDocumentViewController : F4SDCAddUrlViewControllerDelegate {
    func didCaptureUrl(_ url: URL) {
        document.remoteUrlString = url.absoluteString
        delegate?.didAddDocument(document, popIsRequired: popIsRequired)
    }
}

extension F4SDCAddDocumentViewController : F4SCameraCaptureViewControllerDelegate {
    func didCaptureDocumentasPDFData(_ pdfData: Data) {
        dismiss(animated: true, completion: nil)
        document.data = pdfData
        delegate?.didAddDocument(document, popIsRequired: popIsRequired)
        navigationController?.popViewController(animated: true)
    }
}


extension F4SDCAddDocumentViewController : UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // The next line isn't needed, the document picker seems to pop itself
        // navigationController?.popViewController(animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let isUsingScope = url.startAccessingSecurityScopedResource()
        let coordinator = NSFileCoordinator()
        var error:NSError? = nil
        coordinator.coordinate(readingItemAt: url, options: [], error: &error) { (url) -> Void in
            if let fileData = try? Data(contentsOf: url) {
                document.data = fileData
                delegate?.didAddDocument(document, popIsRequired: popIsRequired)
                navigationController?.popViewController(animated: true)
            } else {
                print("No data!!")
            }
        }
        if isUsingScope { url.stopAccessingSecurityScopedResource() }
        if let error = error {
            print(error)
        }
    }
}

extension F4SDCAddDocumentViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        //navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            let pdfData = pickedImage.generatePDF()
            document.data = pdfData
            delegate?.didAddDocument(document, popIsRequired: popIsRequired)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension UIImage {
    func generatePDF() -> Data {
        let data = NSMutableData()
        let a4PortraitRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let a4LandscapeRect = CGRect(x: 0, y: 0, width: 842, height: 595)
        UIGraphicsBeginPDFContextToData(data, a4PortraitRect, nil)
        UIGraphicsBeginPDFPage()
        let targetRect = self.size.height >= self.size.width ? a4PortraitRect : a4LandscapeRect
        let scaledImage = self.aspectFitToSize(targetRect.size)
        let compressedImage = scaledImage.compressTo(0.2)
        compressedImage.draw(in: targetRect)
        UIGraphicsEndPDFContext()
        return data as Data
    }
}











// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}