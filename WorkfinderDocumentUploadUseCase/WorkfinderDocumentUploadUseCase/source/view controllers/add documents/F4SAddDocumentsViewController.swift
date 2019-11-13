import UIKit
import WorkfinderCommon
import WorkfinderUI

class F4SAddDocumentsViewController: UIViewController {
    let consentPreviouslyGivenKey = "consentPreviouslyGivenKey"
    let bigPlusButtonHeightConstraintConstant = CGFloat(60.0)
    
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addDocumentButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var placementUuid: F4SUUID!
    var blRequestModel: F4SBusinessLeadersRequestModel? = nil
    
    @IBOutlet weak var primaryActionButton: UIButton!
    
    weak var coordinator: DocumentUploadCoordinator?
    var log: F4SAnalyticsAndDebugging? { return coordinator?.log }
    var documentModel: F4SDocumentUploadModelBase!
    
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
    
    var uploadScenario: UploadScenario = .applyWorkflow {
        didSet {
            _ = view
            headingLabel.text = uploadScenario.headingText
            subheadingLabel.text = uploadScenario.subheadingText
            addDocumentButton.isHidden = uploadScenario.bigPlusButtonIsHidden
            addButtonHeightConstraint.constant = bigPlusButtonHeightConstraintConstant
        }
    }
    
    var showCancel: Bool {
        switch uploadScenario {
        case .applyWorkflow: return false
        case .businessLeaderRequest(_): return true
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        updateEnabledStateOfAddButton(documentModel)
        applySkin()
    }
    
    @IBAction func addDocumentButtonTapped(_ sender: Any) {
        log?.track(event: .addDocumentsAddDocumentTap, properties: nil)
        hidePopopMenu()
        selectedIndexPath = nil
        coordinator?.showPickMethodForNewDocument(documentTypes: documentTypes, addDocumentDelegate: self)
    }
    
    @IBAction func performPrimaryAction(_ sender: Any) {
        switch uploadScenario {
        case .applyWorkflow:
            performPrimaryActionForApplyMode()
        case .businessLeaderRequest:
            performPrimaryActionForBLRequestMode()
        }
    }
    
    func modeSpecificLoad() {
        switch uploadScenario {
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
        if showCancel {
            let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelTap))
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    @objc func handleCancelTap() {
        coordinator?.documentUploadDidCancel()
    }
    
    @objc func handleInfoTap() {
        log?.track(event: .addDocumentsCVInfoTap, properties: nil)
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
        switch uploadScenario {
        case .applyWorkflow:
            primaryActionButton.isEnabled = true
            if model.numberOfRows(for: 0) == 0 {
                primaryActionButton.setTitle("Skip", for: UIControl.State.normal)
            } else {
                primaryActionButton.setTitle("Upload", for: UIControl.State.normal)
            }
        case .businessLeaderRequest(_):
            primaryActionButton.setTitle("Upload", for: UIControl.State.normal)
            primaryActionButton.isEnabled = model.numberOfRows(for: 0) == 0 ? false : true
        }
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
        switch uploadScenario {
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
            log?.track(event: .addDocumentsShowDocumentOptionsPopupTap, properties: nil)
            let popupCenter = CGPoint(x: cell.frame.origin.x + cell.frame.size.width - popupCellMenu.frame.size.width / 2.0 - 4, y: 0)
            popupCellMenu.isHidden = true
            popupCellMenu.center = cell.convert(popupCenter, to: view)
            popupCellMenu.isHidden = false
            popupCellMenu.context = cell
        } else {
            coordinator?.showPickMethodForDocument(selectedDocument, addDocumentDelegate: self)
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
        case 0: // view document
            log?.track(event: .addDocumentsViewDocumentTap, properties: nil)
            coordinator?.showDocument(selectedDocument)
            
        case 1: // delete
            hidePopopMenu()
            let alert = UIAlertController(title: "Delete Document", message: "Are you sure you want to delete this document?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (_) in
                switch self.uploadScenario {
                case .applyWorkflow:
                    self.log?.track(event: .addDocumentsDeleteDocumentTap, properties: nil)
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

        case 2: // Close menu
            hidePopopMenu()
            
        default: break
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






















