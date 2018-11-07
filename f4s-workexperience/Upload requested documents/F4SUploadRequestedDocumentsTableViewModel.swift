//
//  F4SUploadRequestedDocumentsTableViewModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 24/05/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let uploadRequestSubmitStateUpdated = Notification.Name("uploadRequestSubmitStateUpdated")
    
}

public class F4SUploadRequestedDocumentsTableViewModel {
    
    public private (set) var expandedIndexPath: IndexPath?
    public private (set) var placementUuid: F4SUUID
    
    public convenience init?(action: F4SAction) {
        guard action.actionType == .uploadDocuments, let placementUuid = action.argument(name: F4SActionArgumentName.placementUuid)?.value.first else {
            return nil
        }
        let documentTypeNames = action.argument(name: F4SActionArgumentName.documentType)?.value ?? []
        self.init(placementUuid: placementUuid, documentTypeNames: documentTypeNames)
    }
    
    public init(placementUuid: F4SUUID, documentTypeNames: [String]) {
        self.placementUuid = placementUuid
        documents = documentTypeNames.map({ (docTypeName) -> F4SDocument in
            let docType = F4SUploadableDocumentType(rawValue: docTypeName) ?? F4SUploadableDocumentType.other
            return F4SDocument(type: docType)
        })
    }
    
    private var documents: [F4SDocument] = []
    
    public func toggleExpansionAtIndexPath(indexPath: IndexPath) -> [IndexPath]? {
        if indexPath == expandedIndexPath {
            return collapseExpanded()
        } else {
            return expandAtIndexPath(indexPath)
        }
    }
    
    public func expandAtIndexPath(_ indexPath: IndexPath) -> [IndexPath] {
        if indexPath == expandedIndexPath {
            return [indexPath]
        }
        var affectedIndexPaths : [IndexPath] = [indexPath]
        let currentExpanded = expandedIndexPath
        if currentExpanded != nil {
            documents[currentExpanded!.row].isExpanded = false
            affectedIndexPaths.append(currentExpanded!)
        }
        documents[indexPath.row].isExpanded = true
        expandedIndexPath = indexPath
        return affectedIndexPaths
    }
    
    public func collapseExpanded() -> [IndexPath]? {
        guard let expandedIndexPath = expandedIndexPath else { return nil }
        documents[expandedIndexPath.row].isExpanded = false
        self.expandedIndexPath = nil
        return [expandedIndexPath]
    }
    
    internal var displayUrlDescriptors: [F4SDocument] {
        return documents
    }
    
    public var numberOfSections: Int { return 1 }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return displayUrlDescriptors.count
    }
    
    func postSubmitStateNotification() {
        let notification = Notification(name: .uploadRequestSubmitStateUpdated)
        NotificationCenter.default.post(notification)
    }
    
    public func descriptorForIndexPath(_ indexPath: IndexPath) -> F4SDocument {
        return displayUrlDescriptors[indexPath.row]
    }
    
    public func setDocumentForIndexPath(_ indexPath: IndexPath, title: String = "", type: F4SUploadableDocumentType, urlString: String = "", includeInApplication: Bool = true, isExpanded: Bool = false) -> [IndexPath] {
        let document = F4SDocument(uuid: nil, urlString: urlString, type: type, name: title, includeInApplication: includeInApplication, isExpanded: isExpanded)
        return setDocumentForIndexPath(indexPath, document: document)
    }
    
    public func setDocumentForIndexPath(_ indexPath: IndexPath, document: F4SDocument) -> [IndexPath] {
        documents[indexPath.row] = document
        if indexPath == expandedIndexPath {
            return expandAtIndexPath(indexPath)
        }
        postSubmitStateNotification()
        return [indexPath]
    }
    
    public func urlIsNew(url: URL) -> Bool {
        for document in documents {
            if document.remoteUrl == url { return false }
        }
        return true
    }
    
    public func canSubmitToServer() -> Bool {
        for descriptor in displayUrlDescriptors {
            if !descriptor.hasValidRemoteUrl { return false }
        }
        return true
    }
    
    public func submitToServer(completion: @escaping (F4SNetworkDataResult)->() ) {
        let service = F4SPlacementDocumentsService(placementUuid: placementUuid)
        let putJson = F4SPutDocumentsJson(documents: documents)
        service.putDocumentsForPlacement(documents: putJson) { (result) in
            completion(result)
        }
        
    }
}
