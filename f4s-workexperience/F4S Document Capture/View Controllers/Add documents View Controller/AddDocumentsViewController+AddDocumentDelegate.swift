//
//  AddDocumentsViewController+AddDocumentDelegate.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

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
}
