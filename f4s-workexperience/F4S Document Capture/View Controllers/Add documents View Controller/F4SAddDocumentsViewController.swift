//
//  F4SAddDocumentsViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit
import WorkfinderCommon

class F4SAddDocumentsViewController: UIViewController {
    let consentPreviouslyGivenKey = "consentPreviouslyGivenKey"
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addDocumentButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var applicationContext: F4SApplicationContext!
    var blRequestModel: F4SBusinessLeadersRequestModel? = nil
    
    @IBOutlet weak var primaryActionButton: UIButton!
    
    lazy var documentModel: F4SDocumentUploadModelBase = {
        switch mode {
        case .applyWorkflow:
            return F4SDocumentUploadWhileApplyingModel(delegate: self, placementUuid: self.applicationContext.placement!.placementUuid!)
        case .businessLeaderRequest(let requestModel):
            let placementUuid = requestModel.placementUuid
            let documents = requestModel.documents
            return F4SDocumentUploadAtBLRequestModel(delegate: self, placementUuid: placementUuid, documents: documents)
        }
    }()
    
    lazy var userService: F4SUserService = {
        return F4SUserService()
    }()
    
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
            performPrimaryActionForBLRequestMode()
        }

    }
    
    func popToHere() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    enum Mode {
        case applyWorkflow
        case businessLeaderRequest(F4SBusinessLeadersRequestModel)
        
        var headingText: String {
            switch self {
            case .applyWorkflow:
                return "Stand out from the crowd!"
            case .businessLeaderRequest:
                return "Add requested information"
            }
        }
        
        var subheadingText: String {
            switch self {
            case .applyWorkflow:
                return "Add your CV or any supporting document to make it easier for companies to choose you"
            case .businessLeaderRequest(let requestModel):
                return "Add the documents requested by \(requestModel.companyName) in their recent message to you"
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
                return 60.0
            case .businessLeaderRequest:
                return 60.0
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
        modeSpecificLoad()
        configureNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        applySkin()
    }
    
    func modeSpecificLoad() {
        switch mode {
        case .applyWorkflow:
            sharedUserMessageHandler.showLoadingOverlay(self.view)
            documentModel.fetchDocumentsForPlacement()
        case .businessLeaderRequest:
            break
        }
    }
    
    func configureNavigationItems() {
        let infoImage = #imageLiteral(resourceName: "infoIcon")
        let infoItem = UIBarButtonItem(image: infoImage, style: .plain, target: self, action: #selector(handleInfoTap))
        navigationItem.rightBarButtonItem = infoItem
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelTap))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc func handleCancelTap() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleInfoTap() {
        let alert = UIAlertController(title: "Need help writing your CV?", message: "Barclays have produced a detailed guide", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let goAction = UIAlertAction(title: "View Guide", style: .default) { (_) in
            let barclaysUrl = URL(string: "https://barclayslifeskills.com/i-want-help-applying-for-jobs/school/cv-tips")!
            UIApplication.shared.open(barclaysUrl, options: [:], completionHandler: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(goAction)
        present(alert, animated: true, completion: nil)
    }
    
    func applySkin() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: primaryActionButton)
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = UIColor.white
            navigationBar.tintColor = UIColor.black
            navigationBar.isTranslucent = false
            navigationBar.shadowImage = UIImage()
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
                vc.document = F4SDocument(type: .cv)
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

extension F4SAddDocumentsViewController : F4SDocumentUploadModelDelegate {
    
    func documentUploadModelFailedToFetchDocuments(_ model: F4SDocumentUploadModelBase, error: Error) {
        DispatchQueue.main.async { [unowned self] in
            sharedUserMessageHandler.hideLoadingOverlay()
            self.displayTryAgain {
                sharedUserMessageHandler.showLoadingOverlay(self.view)
                self.documentModel.fetchDocumentsForPlacement()
            }
        }
    }
    
    func documentUploadModelFetchedDocuments(_ model: F4SDocumentUploadModelBase) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadFromModel()
            sharedUserMessageHandler.hideLoadingOverlay()
        }
    }
    
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, deleted: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, updated: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, created: F4SDocument) {
        updateEnabledStateOfAddButton(model)
    }
    
    fileprivate func updateEnabledStateOfAddButton(_ model: F4SDocumentUploadModelBase) {
        addDocumentButton.isEnabled = model.canAddPlaceholder()
    }
    
    fileprivate func reloadFromModel() {
        tableView.reloadData()
        addDocumentButton.isEnabled = documentModel.canAddPlaceholder()
    }
}
    
extension F4SAddDocumentsViewController : UITableViewDataSource, UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
            accessoryImageView.image = shouldDisplayMenuForDocument(document) ? dotImage : nil
            cell.accessoryView = accessoryImageView
        case .businessLeaderRequest:
            cell.textLabel?.text = document.defaultName
            accessoryImageView.image = document.isReadyForUpload ? dotImage : addImage
            cell.accessoryView = accessoryImageView
        }
    }
    
    func shouldDisplayMenuForDocument(_ document: F4SDocument) -> Bool {
        return document.data != nil || document.isViewableOnUrl
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let cell = tableView.cellForRow(at: indexPath), let selectedDocument = selectedDocument else { return }
        if shouldDisplayMenuForDocument(selectedDocument) {
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

extension F4SAddDocumentsViewController : F4SDCPopupMenuViewDelegate {
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
            let alert = UIAlertController(title: "Delete Document", message: "Are you sure you want to delete this document?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (_) in
                switch self.mode {
                case .applyWorkflow:
                    self.documentModel.deleteDocument(indexPath: cellIndexPath)
                    self.tableView.deleteRows(at: [cellIndexPath], with: .automatic)
                    self.addDocumentButton.isEnabled = true
                case .businessLeaderRequest:
                    let type = self.documentModel.document(cellIndexPath).type
                    let clearedPlaceholderDocument = F4SDocument(type: type)
                    self.documentModel.setDocument(clearedPlaceholderDocument, at: cellIndexPath)
                    self.tableView.reloadRows(at: [cellIndexPath], with: .automatic)
                }
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            present(alert, animated: true, completion: nil)

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






















