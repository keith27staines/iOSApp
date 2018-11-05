//
//  AddThreeViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 29/07/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDCAddDocumentsViewController: UIViewController {
    
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addDocumentButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    @IBAction func dismissToOrigin(sender:Any?) {}
    var documents: [F4SDCDocumentUpload] = [F4SDCDocumentUpload]()
    
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
    
    var documentTypes: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        _ = documentTypes
        if mode == Mode.businessLeaderRequest {
            documents = documentTypes.map { (type) -> F4SDCDocumentUpload in
                return F4SDCDocumentUpload(type: type, name: nil, urlString: nil, data: nil)
            }
            tableView.reloadData()
        }
    }
    
    var selectedDocument: F4SDCDocumentUpload? {
        guard let selectedIndexPath = selectedIndexPath else { return nil }
        return documents[selectedIndexPath.row]
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
            }
            
        case "showPickMethodForSelectedDocument":
            if let vc = segue.destination as? F4SDCAddDocumentViewController, let documentType = selectedDocument?.type {
                vc.delegate = self
                vc.documentTypes = [documentType]
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

extension F4SDCAddDocumentsViewController :  F4SDCAddDocumentViewControllerDelegate {
    func didAddDocument(_ document: F4SDCDocumentUpload) {
        popToHere()
        let updatedDocument = document
        if let data = updatedDocument.data {
            let folderUrl = F4SDCDocumentCaptureFileHelper.createDirectory("uploads")
            var url = folderUrl.appendingPathComponent(updatedDocument.name ?? "unnamed", isDirectory: false)
            url = url.appendingPathExtension("pdf")
            do {
                try data.write(to: url, options: [.atomic])
                updatedDocument.localUrlString = url.absoluteString
            } catch {
                print(error)
            }
        }
        if let indexPath = selectedIndexPath {
            documents[indexPath.row] = updatedDocument
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else {
            documents.append(updatedDocument)
            let newIndexPath = IndexPath(row: documents.count-1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            if documents.count == documentTypes.count {
                addDocumentButton.isEnabled = false
            }
            self.selectedIndexPath = newIndexPath
            tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .middle)
        }
    }
    
    func popToHere() {
        if navigationController?.topViewController != self {
            dismiss(animated: true)
        }
    }
}
    
extension F4SDCAddDocumentsViewController : UITableViewDataSource, UITableViewDelegate  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let document = documents[indexPath.row]
        configureCell(cell, with: document)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, with document: F4SDCDocumentUpload) {
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
        documents.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        guard let cell = tableView.cellForRow(at: indexPath), let selectedDocument = selectedDocument else { return }
        if selectedDocument.isReadyForUpload {
            //let popupCenter = CGPoint(x: cell.frame.origin.x + cell.frame.size.width - popupCellMenu.frame.size.width / 2.0 - 4, y: cell.center.y)
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
                documents.remove(at: cellIndexPath.row)
                tableView.deleteRows(at: [cellIndexPath], with: .automatic)
                addDocumentButton.isEnabled = true
            case .businessLeaderRequest:
                documents[cellIndexPath.row].clearAllDetailsExceptType()
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






















