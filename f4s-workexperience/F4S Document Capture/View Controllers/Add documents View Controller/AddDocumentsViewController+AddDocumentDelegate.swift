//
//  AddDocumentsViewController+AddDocumentDelegate.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 06/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

extension F4SDCAddDocumentsViewController :  F4SDCAddDocumentViewControllerDelegate {
    func didAddDocument(_ document: F4SDocument) {
        popToHere()
        if let data = document.data {
            let folderUrl = F4SDCDocumentCaptureFileHelper.createDirectory("uploads")
            var url = folderUrl.appendingPathComponent(document.uuidForiOSFileSystem, isDirectory: false)
            url = url.appendingPathExtension("pdf")
            print(url.path)
            do {
                try data.write(to: url, options: [.atomic])
                document.localUrlString = url.absoluteString
            } catch {
                print(error)
            }
        }
        if let indexPath = selectedIndexPath {
            documentModel.setDocument(document, at: indexPath)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else {
            documentModel.addDocument(document)
            let documentCount = documentModel.numberOfRows(for: 0)
            let newIndexPath = IndexPath(row: documentCount-1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            if documentCount == documentModel.maximumDocumentCount {
                addDocumentButton.isEnabled = false
            }
            self.selectedIndexPath = newIndexPath
            tableView.selectRow(at: newIndexPath, animated: false, scrollPosition: .middle)
        }
    }
}
