//
//  F4SMultiPageDocument.swift
//  DocumentCapture
//
//  Created by Keith Dev on 09/06/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

enum DocumentChange :String {
    case documentModelDidReplacePage
    case documentModelDidRemovePage
    case documentModelDidInsertPage
    case documentModelDidRearrangePages
}

class F4SMultiPageDocument {
    private var pages: [F4SDocumentPage]
    
    init() {
        pages = [F4SDocumentPage]()
    }
    
    func generatePDF() -> Data {
        let data = NSMutableData()
        let a4PortraitRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let a4LandscapeRect = CGRect(x: 0, y: 0, width: 842, height: 595)
        UIGraphicsBeginPDFContextToData(data, a4PortraitRect, nil)
        for page in pages {
            UIGraphicsBeginPDFPage()
            let image = page.image
            let targetRect = image.size.height >= image.size.width ? a4PortraitRect : a4LandscapeRect
            let scaledImage = image.aspectFitToSize(targetRect.size)
            let compressedImage = scaledImage.compressTo(0.2)
            compressedImage.draw(in: targetRect)
        }
        UIGraphicsEndPDFContext()
        return data as Data
    }
    
    var pageCount: Int { return pages.count }
    
    func append(_ page: F4SDocumentPage) {
        pages.append(page)
        let userInfo = ["index": pages.count - 1]
        sendNotification(changeType: .documentModelDidInsertPage, with: userInfo)
    }
    
    func insert(_ page: F4SDocumentPage, index: Int) {
        pages.append(page)
        let userInfo = ["index": index]
        sendNotification(changeType: .documentModelDidInsertPage, with: userInfo)
    }
    
    func replace(existing page: F4SDocumentPage, with newPage: F4SDocumentPage) {
        guard let index = indexForPage(page) else { return }
        pages[index] = newPage
        let userInfo = ["index": index]
        sendNotification(changeType: .documentModelDidReplacePage, with: userInfo)
    }
    
    func remove(_ page: F4SDocumentPage) {
        guard let index = indexForPage(page) else { return }
        pages.remove(at: index)
        let userInfo = ["index": index]
        sendNotification(changeType: .documentModelDidRemovePage, with: userInfo)
    }
    
    func rearrange(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex else { return }
        let p = pages.remove(at: fromIndex)
        pages.insert(p, at: toIndex)
        sendNotification(changeType: .documentModelDidRearrangePages, with: ["fromIndex": fromIndex, "toIndex":toIndex])
    }
    
    func pageAtIndex(_ index: Int) -> F4SDocumentPage {
        return pages[index]
    }
    
    func indexForPage(_ page: F4SDocumentPage) -> Int? {
        return pages.index(where: { (otherPage) -> Bool in
            return otherPage === page
        })
    }
    
    func sendNotification(changeType: DocumentChange, with userInfo: [String: Any]?) {
        let name = Notification.Name(rawValue: changeType.rawValue)
        let notification = Notification(name: name, object: nil, userInfo: userInfo)
        NotificationCenter.default.post(notification)
    }
    
    static func notificationNames() -> [Notification.Name] {
        return [
            Notification.Name.init(rawValue: DocumentChange.documentModelDidInsertPage.rawValue),
            Notification.Name.init(rawValue: DocumentChange.documentModelDidRemovePage.rawValue),
            Notification.Name.init(rawValue: DocumentChange.documentModelDidRearrangePages.rawValue),
            Notification.Name.init(rawValue: DocumentChange.documentModelDidReplacePage.rawValue),
        ]
    }
}
