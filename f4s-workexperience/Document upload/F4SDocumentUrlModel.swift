//
//  F4SDocumentUrlModel.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import Foundation
import UIKit

public struct F4SGetDocumentUrlJson : Codable {
    public let uuid: F4SUUID?
    public let documents: [F4SDocumentUrl]?
}

public struct F4SPutDocumentsUrlJson : Codable {
    public let documents: [F4SDocumentUrl]?
}

public struct F4SDocumentUrl : Codable {
    
    /// url uuid
    public let uuid: F4SUUID?
    
    /// the url of the document
    public let url: String
    
    public let doc_type: String
    public let title: String?
    public let document: String?
    
    
    /// Initializes a new instance
    /// - parameter uuid: The uuid of the url linking to the document
    /// - parameter urlString: The absolute string representation of the url
    /// - parameter doc_type: Describes the type of document
    /// - parameter title: The title of the document if it has one
    public init(uuid: F4SUUID?, urlString: String, doc_type: String = "other", title: String? = nil) {
        self.uuid = uuid
        self.url = urlString
        self.doc_type = doc_type
        self.title = title
        self.document = nil
    }
}

public enum DocType : String {
    case cv
    case certificate
    case other
}

public struct F4SDocumentUrlDescriptor {
    public var title: String = "untitled"
    public var docType: DocType = DocType.other
    public var urlString : String
    public var includeInApplication: Bool = false
    public var isExpanded: Bool = false
    public var uuid: F4SUUID?
    
    public var documentUrl: F4SDocumentUrl {
        return F4SDocumentUrl(uuid: uuid, urlString: urlString, doc_type: docType.rawValue, title: title)
    }
    
    public var isValidUrl: Bool {
        guard let url = self.url else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
    
    public init(title: String = "untitled", docType: DocType = .other, urlString: String, includeInApplication: Bool = false, isExpanded: Bool = false) {
        self.title = title
        self.docType = docType
        self.urlString = urlString
        self.includeInApplication = includeInApplication
        self.isExpanded = isExpanded
        self.uuid = nil
    }
    
    public init(documentUrl: F4SDocumentUrl) {
        self.title = documentUrl.title ?? "untitled"
        self.docType = DocType(rawValue: documentUrl.doc_type) ?? .other
        self.urlString = documentUrl.url
        self.includeInApplication = true
        self.isExpanded = false
        self.uuid = documentUrl.uuid
    }
}

public protocol F4SDocumentUrlModelDelegate {
    func documentUrlModel(_ model: F4SDocumentUrlModel, deleted: F4SDocumentUrlDescriptor)
    func documentUrlModel(_ model: F4SDocumentUrlModel, updated: F4SDocumentUrlDescriptor)
    func documentUrlModel(_ model: F4SDocumentUrlModel, created: F4SDocumentUrlDescriptor)
    func documentUrlModelFetchedDocuments(_ model: F4SDocumentUrlModel)
}

public class F4SDocumentUrlModel {
    
    public private (set) var documentService: F4SPlacementDocumentsService?
    public let maxUrls : Int = 3
    private var delegate: F4SDocumentUrlModelDelegate?
    
    public var expandedIndexPath: IndexPath? {
        for i in 0..<urlDescriptors.count {
            if urlDescriptors[i].isExpanded {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
    
    private var urlDescriptors : [F4SDocumentUrlDescriptor]
    
    public func urlDescriptor(_ indexPath: IndexPath) -> F4SDocumentUrlDescriptor {
        return urlDescriptors[indexPath.row]
    }
    
    public func contains(url: URL) -> Bool {
        for descriptor in urlDescriptors {
            if descriptor.url?.absoluteString == url.absoluteString {
                return true
            }
        }
        return false
    }
    
    public init(urlStrings: [String], delegate: F4SDocumentUrlModelDelegate) {
        self.delegate = delegate
        self.urlDescriptors = []
        for string in urlStrings {
            _ = createDescriptor(urlString: string, includeInApplication: true)
        }
    }
    
    public init(delegate: F4SDocumentUrlModelDelegate, documentService: F4SPlacementDocumentsService? = nil, placementUuid: F4SUUID) {
        if documentService != nil {
            self.documentService = documentService
        } else {
            self.documentService = F4SPlacementDocumentsService(placementUuid: placementUuid)
        }
        self.delegate = delegate
        self.urlDescriptors = []
        self.documentService?.getDocumentsForPlacement(completion: documentsFetched)
    }
    
    func putDocumentsUrls(completion: @escaping (Bool) -> Void ) {
        let validDescriptors = self.urlDescriptors.filter { (descriptor) -> Bool in
            return descriptor.isValidUrl
        }
        let documentUrls = validDescriptors.map { (descriptor) -> F4SDocumentUrl in
            return descriptor.documentUrl
        }
        let putJson = F4SPutDocumentsUrlJson(documents: documentUrls)
        documentService?.putDocumentsForPlacement(documentDescriptors: putJson, completion: { (result) in
            switch result {
            case .success(let msg):
                print(msg)
                completion(true)
            case .error(let error):
                print(error)
                break
            }
        })
    }
    
    func documentsFetched(networkResult: F4SNetworkResult<F4SGetDocumentUrlJson>) {
        switch networkResult {
        case .error(_):
            break
        case .success(let documentDownload):
            urlDescriptors = []
            if let documentUrls = documentDownload.documents {
                for documentUrl in documentUrls  {
                    _ = createDescriptor(documentUrl: documentUrl)
                }
            }
            delegate?.documentUrlModelFetchedDocuments(self)
        }
    }
    
    func canAddPlaceholder() -> Bool {
        return urlDescriptors.count < maxUrls ? true : false
    }
    
    func doAllDescriptorsContainValidLinks() -> Bool {
        for descriptor in urlDescriptors {
            if !descriptor.isValidUrl {
                return false
            }
        }
        return true
    }
    
    func setDescriptor(_ descriptor: F4SDocumentUrlDescriptor, at indexPath: IndexPath) {
        urlDescriptors[indexPath.row] = descriptor
        delegate?.documentUrlModel(self, updated: descriptor)
    }
    
    func expandDescriptor(at indexPath: IndexPath) {
        collapseAllRows()
        var descriptor = urlDescriptors[indexPath.row]
        descriptor.isExpanded = true
        urlDescriptors[indexPath.row] = descriptor
    }
    
    public func collapseAllRows() {
        for (index,descriptor) in urlDescriptors.enumerated() {
            var descr = descriptor
            descr.isExpanded = false
            urlDescriptors[index] = descr
        }
    }
    
    func deleteDescriptor(indexPath: IndexPath) {
        let removed = urlDescriptors[indexPath.row]
        urlDescriptors.remove(at: indexPath.row)
        delegate?.documentUrlModel(self, deleted: removed)
    }
    
    func createDescriptor(documentUrl: F4SDocumentUrl) -> F4SDocumentUrlDescriptor? {
        if !canAddPlaceholder() { return nil }
        let newDescriptor = F4SDocumentUrlDescriptor(documentUrl: documentUrl)
        urlDescriptors.insert(newDescriptor, at: 0)
        delegate?.documentUrlModel(self, created: newDescriptor)
        return newDescriptor
    }
    
    func createDescriptor(urlString: String = "", includeInApplication: Bool) -> F4SDocumentUrlDescriptor? {
        if !canAddPlaceholder() { return nil }
        let newDescriptor = F4SDocumentUrlDescriptor(title: "untitled", docType: DocType.other, urlString: urlString, includeInApplication: includeInApplication, isExpanded: false)
        urlDescriptors.insert(newDescriptor, at: 0)
        delegate?.documentUrlModel(self, created: newDescriptor)
        return newDescriptor
    }
}

extension F4SDocumentUrlModel {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(for section: Int) -> Int {
        return urlDescriptors.count
    }
}
