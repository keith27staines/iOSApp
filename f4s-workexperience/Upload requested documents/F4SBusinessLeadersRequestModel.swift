//
//  F4SBusinessLeadersRequestModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public class F4SBusinessLeadersRequestModel {
    
    public private (set) var placementUuid: F4SUUID
    private var documents: [F4SDocument] = []
    
    public convenience init?(action: F4SAction) {
        guard action.actionType == .uploadDocuments, let placementUuid = action.argument(name: F4SActionArgumentName.placementUuid)?.value.first else {
            return nil
        }
        let documentTypeNames = action.argument(name: F4SActionArgumentName.documentType)?.value ?? []
        self.init(placementUuid: placementUuid, documentTypeNames: documentTypeNames)
    }
    
    private init(placementUuid: F4SUUID, documentTypeNames: [String]) {
        self.placementUuid = placementUuid
        documents = documentTypeNames.map({ (docTypeName) -> F4SDocument in
            let docType = F4SUploadableDocumentType(rawValue: docTypeName) ?? F4SUploadableDocumentType.other
            return F4SDocument(type: docType)
        })
    }
    
    public var numberOfSections: Int { return 1 }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return documents.count
    }
}
