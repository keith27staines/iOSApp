//
//  F4SDocumentModel.swift
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

extension UIImage {
    
    /// returns an image scaled to the specified size
    ///
    /// - parameter size: The size to scale the image to (not preserving aspect ratio)
    func scaledImage(with size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    /// Returns the largest image scaled to fit within the specified size but preserving the original apsect ratio
    ///
    /// - parameter size: The size to fit the image to
    func aspectFitToSize(_ size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return scaledImage(with: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return scaledImage(with: CGSize(width: size.height * aspect, height: size.height))
        }
    }
    
    /// Returns a compressed image not exceeding the specifed size in MB
    ///
    /// - parameter requiredSize: The maximum size of the compressed image
    func compressTo(_ requiredSize: Double) -> UIImage {
        let requiredSizeInBytes = Int(requiredSize * 1024 * 1024)
        var needsMoreCompression: Bool = true
        var quality: CGFloat = 1.0
        var data = self.jpegData(compressionQuality: quality)!
        while (needsMoreCompression && quality > 0.1) {
            
            if data.count <= requiredSizeInBytes {
                needsMoreCompression = false
            } else {
                quality -= 0.1
                data = self.jpegData(compressionQuality: quality)!
            }
        }
        return UIImage(data: data)!
    }
}

class F4SDocumentModel {
    private var pages: [F4SDocumentPageModel]
    
    init() {
        pages = [F4SDocumentPageModel]()
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
    
    func append(_ page: F4SDocumentPageModel) {
        pages.append(page)
        let userInfo = ["index": pages.count - 1]
        sendNotification(changeType: .documentModelDidInsertPage, with: userInfo)
    }
    
    func insert(_ page: F4SDocumentPageModel, index: Int) {
        pages.append(page)
        let userInfo = ["index": index]
        sendNotification(changeType: .documentModelDidInsertPage, with: userInfo)
    }
    
    func replace(existing page: F4SDocumentPageModel, with newPage: F4SDocumentPageModel) {
        guard let index = indexForPage(page) else { return }
        pages[index] = newPage
        let userInfo = ["index": index]
        sendNotification(changeType: .documentModelDidReplacePage, with: userInfo)
    }
    
    func remove(_ page: F4SDocumentPageModel) {
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
    
    func pageAtIndex(_ index: Int) -> F4SDocumentPageModel {
        return pages[index]
    }
    
    func indexForPage(_ page: F4SDocumentPageModel) -> Int? {
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

class F4SDocumentPageModel {
    var image: UIImage
    init(text: String) {
        image = F4SDocumentPageModel.createImage(text: text)
    }
    
    static func createImage(text: String) -> UIImage {
        let width: CGFloat = 1000
        let height:CGFloat = 1000 * 1.4142
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { (rendererContext) in
            let context = rendererContext.cgContext
            let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
            context.setFillColor(UIColor.lightGray.cgColor)
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(6)
            context.addRect(rectangle)
            context.drawPath(using: .fillStroke)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attrs = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 1000)!, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            context.setFillColor(UIColor.black.cgColor)
            text.draw(with: CGRect(x: 10, y: 10, width: 980, height: 1380), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
        return image
    }
}
