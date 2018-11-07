//
//  AddThreeViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDCAddDocumentsViewController: UIViewController {
    let consentPreviouslyGivenKey = "consentPreviouslyGivenKey"
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addDocumentButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    

    @IBOutlet weak var primaryActionButton: UIButton!
    
    lazy var documentModel: F4SDocumentUploadModel = {
        return F4SDocumentUploadModel(delegate: self, placementUuid: self.applicationContext.placement!.placementUuid!)
    }()
    
    lazy var userService: F4SUserService = {
        return F4SUserService()
    }()
    
    var applicationContext: F4SApplicationContext!
    
    @IBAction func addDocumentButtonTapped(_ sender: Any) {
        hidePopopMenu()
        selectedIndexPath = nil
        performSegue(withIdentifier: "showPickMethod", sender: self)
    }
    
    lazy var popupCellMenu: F4SDCPopupMenuView = {
        let frame = CGRect(x: 0, y: 0, width: 150, height: 120)
        let popup = F4SDCPopupMenuView(frame: frame)
        popup.backgroundColor = UIColor.lightGray
        popup.items = ["View", "Delete","Close"]
        view.addSubview(popup)
        popup.isHidden = true
        popup.delegate = self
        return popup
    }()
    
    @IBAction func performPrimaryAction(_ sender: Any) {
        switch mode {
        case .applyWorkflow:
            performPrimaryActionForApplyMode()
        case .businessLeaderRequest:
            break
        }

    }
    
    @IBAction func unwindToAddDocuments(segue: UIStoryboardSegue) {}
    
    func popToHere() {
        if navigationController?.topViewController != self {
            dismiss(animated: true)
        }
    }
    
    enum Mode {
        case applyWorkflow
        case businessLeaderRequest
        
        var headingText: String {
            switch self {
            case .applyWorkflow:
                return "Stand out from the crowd!"
            case .businessLeaderRequest:
                return "Please add the information requested"
            }
        }
        
        var subheadingText: String {
            switch self {
            case .applyWorkflow:
                return "Make it easier for companies to choose you by adding your experience"
            case .businessLeaderRequest:
                return "" // Upload the information requested"
            }
        }
        
        var bigPlusButtonIsHidden: Bool {
            switch self {
            case .applyWorkflow:
                return false
            case .businessLeaderRequest:
                return true
            }
        }
        
        var bigPlusButtonHeightConstraintConstant: CGFloat {
            switch self {
            case .applyWorkflow:
                return 50.0
            case .businessLeaderRequest:
                return 0.0
            }
        }
    }
    
    var mode: Mode = .applyWorkflow {
        didSet {
            _ = view
            headingLabel.text = mode.headingText
            subheadingLabel.text = mode.subheadingText
            addDocumentButton.isHidden = mode.bigPlusButtonIsHidden
            addButtonHeightConstraint.constant = mode.bigPlusButtonHeightConstraintConstant
        }
    }
    
    var documentTypes: [F4SUploadableDocumentType] = F4SUploadableDocumentType.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        applySkin()
        switch mode {

        case .applyWorkflow:
            MessageHandler.sharedInstance.showLoadingOverlay(self.view)
            documentModel.fetchDocumentsForPlacement()
        case .businessLeaderRequest:
            break
        }
    }
    
    func applySkin() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: primaryActionButton)
    }
    
    var selectedDocument: F4SDocument? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        return documentModel.document(selectedIndexPath)
    }
    
    var selectedIndexPath: IndexPath? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier {
        case "showNext":
            break
            
        case "showPickMethod":
            if let vc = segue.destination as? F4SDCAddDocumentViewController {
                vc.delegate = self
                vc.documentTypes = documentTypes
                vc.document = F4SDocument(type: .other)
            }
            
        case "showPickMethodForSelectedDocument":
            if let vc = segue.destination as? F4SDCAddDocumentViewController,
                let selectedDocument = self.selectedDocument {
                vc.delegate = self
                vc.documentTypes = [selectedDocument.type]
                vc.document = selectedDocument
            }
            
        case "showDocument":
            guard let document = selectedDocument else { return }
            if let vc = segue.destination as? F4SDCDocumentViewerController {
                vc.document = document
            }
            
        default:
            break
        }
    }
}

extension F4SDCAddDocumentsViewController : F4SDocumentUploadModelDelegate {
    func documentUploadModelFailedToFetchDocuments(_ model: F4SDocumentUploadModel, error: Error) {
        DispatchQueue.main.async { [unowned self] in
            MessageHandler.sharedInstance.hideLoadingOverlay()
            self.displayTryAgain {
                MessageHandler.sharedInstance.showLoadingOverlay(self.view)
                self.documentModel.fetchDocumentsForPlacement()
            }
        }
    }
    
    func documentUploadModelFetchedDocuments(_ model: F4SDocumentUploadModel) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadFromModel()
            MessageHandler.sharedInstance.hideLoadingOverlay()
        }
    }
    
    func documentUploadModel(_ model: F4SDocumentUploadModel, deleted: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    func documentUploadModel(_ model: F4SDocumentUploadModel, updated: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    func documentUploadModel(_ model: F4SDocumentUploadModel, created: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    
    fileprivate func updateEnabledStateOfAddButton(_ model: F4SDocumentUploadModel) {
        addDocumentButton.isEnabled = model.canAddPlaceholder()
    }
    
    fileprivate func reloadFromModel() {
        tableView.reloadData()
        addDocumentButton.isEnabled = documentModel.canAddPlaceholder()
    }
}
    
extension F4SDCAddDocumentsViewController : UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentModel.numberOfRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let document = documentModel.document(indexPath)
        configureCell(cell, with: document)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, with document: F4SDocument) {
        cell.accessoryType = .none
        let dotImage = UIImage(named: "ui-submenudots-icon")
        let addImage = UIImage(named: "ui-photoplus-icon")
        let accessoryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessoryImageView.contentMode = .scaleAspectFit
        switch mode {
        case .applyWorkflow:
            cell.textLabel?.text = document.defaultName
            accessoryImageView.image = document.isReadyForUpload ? dotImage : nil
            cell.accessoryView = accessoryImageView
        case .businessLeaderRequest:
            cell.textLabel?.text = document.defaultName
            accessoryImageView.image = document.isReadyForUpload ? dotImage : addImage
            cell.accessoryView = accessoryImageView
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        documentModel.deleteDocument(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let cell = tableView.cellForRow(at: indexPath), let selectedDocument = selectedDocument else { return }
        if selectedDocument.isReadyForUpload {
            let popupCenter = CGPoint(x: cell.frame.origin.x + cell.frame.size.width - popupCellMenu.frame.size.width / 2.0 - 4, y: 0)
            popupCellMenu.isHidden = true
            popupCellMenu.center = cell.convert(popupCenter, to: view)
            popupCellMenu.isHidden = false
            popupCellMenu.context = cell
        } else {
            performSegue(withIdentifier: "showPickMethodForSelectedDocument", sender: self)
        }
    }
}

extension F4SDCAddDocumentsViewController : F4SDCPopupMenuViewDelegate {
    func popupMenu(_ menu: F4SDCPopupMenuView, didSelectRowAtIndex index: Int) {
        guard
            let cell = menu.context as? UITableViewCell,
            let cellIndexPath = tableView.indexPath(for: cell)
        else { return }
        
        switch index {
        case 0:
            // view
            performSegue(withIdentifier: "showDocument", sender: self)
            
        case 1:
            // delete
            hidePopopMenu()
            switch mode {
            case .applyWorkflow:
                documentModel.deleteDocument(indexPath: cellIndexPath)
                tableView.deleteRows(at: [cellIndexPath], with: .automatic)
                addDocumentButton.isEnabled = true
            case .businessLeaderRequest:
                let type = documentModel.document(cellIndexPath).type
                let clearedPlaceholderDocument = F4SDocument(type: type)
                documentModel.setDocument(clearedPlaceholderDocument, at: cellIndexPath)
                tableView.reloadRows(at: [cellIndexPath], with: .automatic)
            }

            break
        case 2:
            // Close menu
            hidePopopMenu()
            
        default:
            break
        }
    }
    
    func hidePopopMenu() {
        popupCellMenu.isHidden = true
        if let selectedIndexPath = selectedIndexPath {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
}

extension String
{
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
}






















