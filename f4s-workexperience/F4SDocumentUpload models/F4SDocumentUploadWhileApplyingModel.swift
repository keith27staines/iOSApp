//
//  F4SDocumentUploadModel.swift
//  UrlUploadDemo
//
//  Created by Keith Dev on 16/02/2018.
//  Copyright © 2018 Keith Dev. All rights reserved.
//

import UIKit
import WorkfinderCommon

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
    
    public var documentServerUrlString: String?
    
    public var viewableUrlString: String? {
        if isOptionalUrlStringOpenable(documentServerUrlString) { return documentServerUrlString}
        if isOptionalUrlStringOpenable(remoteUrlString) { return remoteUrlString }
        return localUrlString // local url will be viewable if it exists
    }
    
    
    /// The url where the document can be viewed (might be local, might be remote)
    var viewableUrl: URL? {
        guard let urlString = viewableUrlString else { return nil }
        return URL(string: urlString)
    }

    private func isOptionalUrlStringOpenable(_ urlString: String?) -> Bool {
        guard
            let string = urlString,
            string.isEmpty == false,
            let url = URL(string: string),
            UIApplication.shared.canOpenURL(url) else { return false }
        return true
    }

    var isViewableOnUrl: Bool {
        guard let url = viewableUrl, UIApplication.shared.canOpenURL(url) else { return false }
        return true
    }
    
    public var type: F4SUploadableDocumentType = .other
    public var name: String?
    public var data: Data? = nil
    
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
        if isUploaded { return false }
        if let realData = data, realData.count > 0 { return true }
        guard let remoteUrlString = remoteUrlString,
            let url = URL(string: remoteUrlString),
            UIApplication.shared.canOpenURL(url) else {
                return false
        }
        return true
    }
    
    var isUploaded: Bool = false
    
    var defaultName: String {
        return "My \(type)"
    }
    
    /// Initializes a new instance
    /// - parameter uuid: The uuid of the url linking to the document
    /// - parameter urlString: The absolute string representation of the url where the document is permantently stored
    /// - parameter type: Describes the type of document
    /// - parameter name: The name of the document if it has one
    public init(uuid: F4SUUID? = nil,
                urlString: String? = nil,
                type: F4SUploadableDocumentType = .other,
                name: String? = nil) {
        self.uuid = uuid
        self.remoteUrlString = urlString
        self.type = type
        self.name = name ?? type.name
        self.data = nil
    }
}

extension F4SDocument {
    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case documentServerUrlString = "document"
        case remoteUrlString = "url"
        case type = "doc_type"
        case name = "title"
    }
}

public protocol F4SDocumentUploadModelDelegate {
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, deleted: F4SDocument)
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, updated: F4SDocument)
    func documentUploadModel(_ model: F4SDocumentUploadModelBase, created: F4SDocument)
    func documentUploadModelFetchedDocuments(_ model: F4SDocumentUploadModelBase)
    func documentUploadModelFailedToFetchDocuments(_ model: F4SDocumentUploadModelBase, error: Error)
}

public class F4SDocumentUploadModelBase {
    public fileprivate (set) var placementDocumentService: F4SPlacementDocumentsService?
    public fileprivate (set) var userDocumentService: F4SPlacementDocumentServiceProtocol? // F4SUserDocumentsServiceProtocol?
    
    public var maximumDocumentCount : Int { return 2 }
    
    fileprivate var delegate: F4SDocumentUploadModelDelegate?
    fileprivate var documents : [F4SDocument]
    
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
    
    public func setDocument(_ document: F4SDocument, at indexPath: IndexPath) {
        documents[indexPath.row] = document
        delegate?.documentUploadModel(self, updated: document)
    }
    
    public func canAddPlaceholder() -> Bool {
        return documents.count <= maximumDocumentCount ? true : false
    }
    
    /// Must override
    public func fetchDocumentsForPlacement() { assertionFailure("Must be overridden") }
    
    public func putDocumentsWithRemoteUrls(completion: @escaping (Bool) -> Void ) {
        let documentsWithRemoteUrl = self.documents.filter { (document) -> Bool in
            return document.hasValidRemoteUrl
        }
        let putJson = F4SPutDocumentsJson(documents: documentsWithRemoteUrl)
        placementDocumentService?.putDocuments(documents: putJson, completion: { (result) in
            switch result {
            case .success(_):
                completion(true)
            case .error(let error):
                globalLog.debug(error)
                completion(false)
                break
            }
        })
    }
    
    public func documentsWithData() -> [F4SDocument] {
        return documents.filter({ (document) -> Bool in
            return document.data != nil && document.uuid == nil && document.isUploaded == false
        })
    }
    
    public func doAllDescriptorsContainValidLinks() -> Bool {
        for descriptor in documents {
            if !descriptor.hasValidRemoteUrl {
                return false
            }
        }
        return true
    }
    
    public func deleteDocument(indexPath: IndexPath) {
        let removed = documents[indexPath.row]
        documents.remove(at: indexPath.row)
        delegate?.documentUploadModel(self, deleted: removed)
    }
    
    @discardableResult
    public func addDocument(_ document: F4SDocument) -> F4SDocument? {
        if !canAddPlaceholder() { return nil }
        documents.append(document)
        delegate?.documentUploadModel(self, created: document)
        return document
    }
    
    public init(delegate: F4SDocumentUploadModelDelegate, documentService: F4SPlacementDocumentsService) {
        self.delegate = delegate
        self.placementDocumentService = documentService
        self.userDocumentService = documentService //F4SUserDocumentsService()
        self.documents = []
    }
    
    public init(delegate: F4SDocumentUploadModelDelegate, placementUuid: F4SUUID) {
        let documentService = F4SPlacementDocumentsService(placementUuid: placementUuid)
        self.delegate = delegate
        self.placementDocumentService = documentService
        self.userDocumentService = documentService //F4SUserDocumentsService()
        self.documents = []
    }
    
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfRows(for section: Int) -> Int {
        return documents.count
    }
}

public class F4SDocumentUploadAtBLRequestModel : F4SDocumentUploadModelBase {
    
    public init(delegate: F4SDocumentUploadModelDelegate, placementUuid: F4SUUID, documents: [F4SDocument]) {
        super.init(delegate: delegate, placementUuid: placementUuid)
        self.documents = documents
    }
    
    override public var maximumDocumentCount: Int { return documents.count }
    override public func canAddPlaceholder() -> Bool { return false }
    
    @discardableResult
    override public func addDocument(_ document: F4SDocument) -> F4SDocument? { return nil }
    
    override public func deleteDocument(indexPath: IndexPath) {
        let type = document(indexPath).type
        setDocument(F4SDocument(type: type), at: indexPath)
    }
    
    override public func setDocument(_ document: F4SDocument, at indexPath: IndexPath) {
        indexPathLastUpdated = indexPath
        super.setDocument(document, at: indexPath)
    }

    public private (set) var indexPathLastUpdated: IndexPath? = nil
}

public class F4SDocumentUploadWhileApplyingModel : F4SDocumentUploadModelBase {
    
    override public func fetchDocumentsForPlacement() {
        self.documents = []
        self.userDocumentService?.getDocuments(completion: documentsFetched)
    }
    
    private func documentsFetched(networkResult: F4SNetworkResult<F4SGetDocumentJson>) {
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

}
