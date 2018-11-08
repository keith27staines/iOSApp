//
//  F4SDocumentUploadModel.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit

public struct F4SGetDocumentJson : Codable {
    public let uuid: F4SUUID?
    public let documents: [F4SDocument]?
}

public struct F4SPutDocumentsJson : Codable {
    public let documents: [F4SDocument]?
}

public enum F4SUploadableDocumentType : String, CaseIterable, Codable {
    case cv
    case other
    
    var name: String {
        switch self {
        case .cv:
            return "CV"
        case .other:
            return "Other"
        }
    }
}

public class F4SDocument : Codable {
    
    static public let defaultTitle = "untitled"
    
    /// F4S uuid of the document
    public var uuid: F4SUUID?
    
    public var uuidForiOSFileSystem: String = UUID().uuidString
    
    /// The (perhaps temporary) url where the document is currently located on this device, prior to upload
    var localUrlString: String? = nil
    
    /// the remote url of the document
    public var remoteUrlString: String?
    
    /// The url string (can be remote or local) defining where the document can be viewed
    var viewableUrlString: String? {
        return remoteUrlString ?? localUrlString
    }
    
    /// The url where the document can be viewed
    var viewableUrl: URL? {
        guard let urlString = viewableUrlString else { return nil }
        return URL(string: urlString)
    }
    
    public var type: F4SUploadableDocumentType = .other
    public var name: String?
    public var data: Data? = nil
    
    public var includeInApplication: Bool = false
    public var isExpanded: Bool = false
    
    public var hasValidRemoteUrl: Bool {
        guard let remoteUrl = self.remoteUrl else {
            return false
        }
        return UIApplication.shared.canOpenURL(remoteUrl)
    }
    
    /// The remote url where the document should be available
    public var remoteUrl: URL? {
        guard let remoteUrlString = remoteUrlString else { return nil }
        return URL(string: remoteUrlString)
    }
    
    var isReadyForUpload: Bool {
        if let realData = data, realData.count > 0 { return true }
        guard let remoteUrlString = remoteUrlString,
            let url = URL(string: remoteUrlString),
            UIApplication.shared.canOpenURL(url) else {
                return false
        }
        return true
    }
    
    var defaultName: String {
        return "My \(type)"
    }
    
    /// Initializes a new instance
    /// - parameter uuid: The uuid of the url linking to the document
    /// - parameter urlString: The absolute string representation of the url where the document is permantently stored
    /// - parameter type: Describes the type of document
    /// - parameter name: The name of the document if it has one
    /// - parameter includeInApplication: Specifies whether to include this document in the current application
    /// - paraemter isExpanded: For use by the UI
    public init(uuid: F4SUUID? = nil,
                urlString: String? = nil,
                type: F4SUploadableDocumentType = .other,
                name: String? = nil,
                includeInApplication: Bool = false,
                isExpanded: Bool = false) {
        self.uuid = uuid
        self.remoteUrlString = urlString
        self.type = type
        self.name = name ?? type.name
        self.isExpanded = isExpanded
        self.includeInApplication = includeInApplication
        self.data = nil
    }
}

extension F4SDocument {
    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case remoteUrlString = "url"
        case type = "doc_type"
        case name = "title"
    }
}

public protocol F4SDocumentUploadModelDelegate {
    func documentUploadModel(_ model: F4SDocumentUploadModel, deleted: F4SDocument)
    func documentUploadModel(_ model: F4SDocumentUploadModel, updated: F4SDocument)
    func documentUploadModel(_ model: F4SDocumentUploadModel, created: F4SDocument)
    func documentUploadModelFetchedDocuments(_ model: F4SDocumentUploadModel)
    func documentUploadModelFailedToFetchDocuments(_ model: F4SDocumentUploadModel, error: Error)
}

public class F4SDocumentUploadModel {
    
    public private (set) var documentService: F4SPlacementDocumentsService?
    public let maximumDocumentCount : Int = 2
    private var delegate: F4SDocumentUploadModelDelegate?
    
    public var expandedIndexPath: IndexPath? {
        for i in 0..<documents.count {
            if documents[i].isExpanded {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
    
    private var documents : [F4SDocument]
    
    public func document(_ indexPath: IndexPath) -> F4SDocument {
        return documents[indexPath.row]
    }
    
    public func contains(url: URL) -> Bool {
        for document in documents {
            if document.remoteUrl?.absoluteString == url.absoluteString {
                return true
            }
        }
        return false
    }
    
    public init(urlStrings: [String], delegate: F4SDocumentUploadModelDelegate) {
        self.delegate = delegate
        self.documents = []
        for string in urlStrings {
            _ = createDescriptor(urlString: string, includeInApplication: true)
        }
    }
    
    public init(delegate: F4SDocumentUploadModelDelegate, documentService: F4SPlacementDocumentsService? = nil, placementUuid: F4SUUID) {
        if documentService != nil {
            self.documentService = documentService
        } else {
            self.documentService = F4SPlacementDocumentsService(placementUuid: placementUuid)
        }
        self.delegate = delegate
        self.documents = []
    }
    
    public func fetchDocumentsForPlacement() {
        self.documents = []
        self.documentService?.getDocumentsForPlacement(completion: documentsFetched)
    }
    
    func putDocuments(completion: @escaping (Bool) -> Void ) {
        let validDocuments = self.documents.filter { (document) -> Bool in
            return document.hasValidRemoteUrl
        }
        let putJson = F4SPutDocumentsJson(documents: validDocuments)
        documentService?.putDocumentsForPlacement(documents: putJson, completion: { (result) in
            switch result {
            case .success(_):
                completion(true)
            case .error(let error):
                log.debug(error)
                completion(false)
                break
            }
        })
    }
    
    func documentsFetched(networkResult: F4SNetworkResult<F4SGetDocumentJson>) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            switch networkResult {
            case .error(let error):
                this.delegate?.documentUploadModelFailedToFetchDocuments(this, error: error)
            case .success(let documentDownload):
                this.documents = []
                if let documents = documentDownload.documents {
                    for document in documents  {
                        this.addDocument(document)
                    }
                }
                this.delegate?.documentUploadModelFetchedDocuments(this)
            }
        }
    }
    
    func canAddPlaceholder() -> Bool {
        return documents.count <= maximumDocumentCount ? true : false
    }
    
    func doAllDescriptorsContainValidLinks() -> Bool {
        for descriptor in documents {
            if !descriptor.hasValidRemoteUrl {
                return false
            }
        }
        return true
    }
    
    func setDocument(_ document: F4SDocument, at indexPath: IndexPath) {
        documents[indexPath.row] = document
        delegate?.documentUploadModel(self, updated: document)
    }
    
    func expandDocument(at indexPath: IndexPath) {
        collapseAllRows()
        var descriptor = documents[indexPath.row]
        descriptor.isExpanded = true
        documents[indexPath.row] = descriptor
    }
    
    public func collapseAllRows() {
        for (index,descriptor) in documents.enumerated() {
            var descr = descriptor
            descr.isExpanded = false
            documents[index] = descr
        }
    }
    
    func deleteDocument(indexPath: IndexPath) {
        let removed = documents[indexPath.row]
        documents.remove(at: indexPath.row)
        delegate?.documentUploadModel(self, deleted: removed)
    }
    
    @discardableResult
    func addDocument(_ document: F4SDocument) -> F4SDocument? {
        if !canAddPlaceholder() { return nil }
        documents.append(document)
        delegate?.documentUploadModel(self, created: document)
        return document
    }
    
    func createDescriptor(urlString: String = "", includeInApplication: Bool) -> F4SDocument? {
        if !canAddPlaceholder() { return nil }
        
        let newDocument = F4SDocument(uuid: nil, urlString: urlString, type: .other, name: "untitled", includeInApplication: includeInApplication, isExpanded: false)
        documents.insert(newDocument, at: 0)
        delegate?.documentUploadModel(self, created: newDocument)
        return newDocument
    }
}

extension F4SDocumentUploadModel {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows(for section: Int) -> Int {
        return documents.count
    }
}
