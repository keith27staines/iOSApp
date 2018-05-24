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
    public private (set) var placementUuid: F4SUUID?
    
    public convenience init?(action: F4SAction) {
        guard action.actionType == .uploadDocuments else { return nil }
        let documentTypeNames = action.argument(name: F4SActionArgumentName.documentType)?.value ?? []
        let placementUuid = action.argument(name: F4SActionArgumentName.placementUuid)?.value.first
        self.init(placementUuid: placementUuid, documentTypeNames: documentTypeNames)
    }
    
    public init(placementUuid: F4SUUID?, documentTypeNames: [String]) {
        documentUrlDescriptors = documentTypeNames.map({ (docTypeName) -> F4SDocumentUrlDescriptor in
            let docType = F4SUploadableDocumentType(rawValue: docTypeName) ?? F4SUploadableDocumentType.other
            return F4SDocumentUrlDescriptor(title: "", docType: docType, urlString: "", includeInApplication: true, isExpanded: false)
        }).sorted(by: {(descriptor1, decriptor2) -> Bool in
            expandedIndexPath = nil
            return descriptor1.docType != .lifeskills
        })
        self.placementUuid = placementUuid
    }
    
    private var documentUrlDescriptors: [F4SDocumentUrlDescriptor] = []
    
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
            documentUrlDescriptors[currentExpanded!.row].isExpanded = false
            affectedIndexPaths.append(currentExpanded!)
        }
        documentUrlDescriptors[indexPath.row].isExpanded = true
        expandedIndexPath = indexPath
        return affectedIndexPaths
    }
    
    public func collapseExpanded() -> [IndexPath]? {
        guard let expandedIndexPath = expandedIndexPath else { return nil }
        documentUrlDescriptors[expandedIndexPath.row].isExpanded = false
        self.expandedIndexPath = nil
        return [expandedIndexPath]
    }
    
    internal var displayUrlDescriptors: [F4SDocumentUrlDescriptor] {
        if userHasLifeskillsCertificate {
            return documentUrlDescriptors
        } else {
            return documentUrlDescriptors.filter({ (descriptor) -> Bool in
                descriptor.docType != F4SUploadableDocumentType.lifeskills
            })
        }
    }
    
    public var numberOfSections: Int { return 1 }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return displayUrlDescriptors.count
    }
    
    public var userHasLifeskillsCertificate: Bool = false {
        didSet {
            postSubmitStateNotification()
        }
    }
    
    func postSubmitStateNotification() {
        let notification = Notification(name: .uploadRequestSubmitStateUpdated)
        NotificationCenter.default.post(notification)
    }
    
    public var isLifeSkillsCertificateRequested: Bool {
        return documentUrlDescriptors.contains(where: { (descriptor) -> Bool in
            return descriptor.docType == F4SUploadableDocumentType.lifeskills
        })
    }
    
    public func descriptorForIndexPath(_ indexPath: IndexPath) -> F4SDocumentUrlDescriptor {
        return displayUrlDescriptors[indexPath.row]
    }
    
    public func setDescriptorForIndexPath(_ indexPath: IndexPath, title: String = "", type: F4SUploadableDocumentType, urlString: String = "", includeInApplication: Bool = true, isExpanded: Bool = false) -> [IndexPath] {
        let descriptor = F4SDocumentUrlDescriptor(title: title, docType: type, urlString: urlString, includeInApplication: includeInApplication, isExpanded: isExpanded)
        return setDescriptorForIndexPath(indexPath, descriptor: descriptor)
    }
    
    public func setDescriptorForIndexPath(_ indexPath: IndexPath, descriptor: F4SDocumentUrlDescriptor) -> [IndexPath] {
        documentUrlDescriptors[indexPath.row] = descriptor
        if indexPath == expandedIndexPath {
            return expandAtIndexPath(indexPath)
        }
        postSubmitStateNotification()
        return [indexPath]
    }
    
    public func urlIsNew(url: URL) -> Bool {
        for descriptor in documentUrlDescriptors {
            if descriptor.url == url { return false }
        }
        return true
    }
    
    public func canSubmitToServer() -> Bool {
        for descriptor in displayUrlDescriptors {
            if !descriptor.isValidUrl { return false }
        }
        return true
    }
    
    public func submitToServer(completion: ()->() ) {
        
    }
}
