//
//  F4SBusinessLeadersRequestModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 08/11/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon
import WorkfinderServices

public class F4SBusinessLeadersRequestModel {
    
    public private (set) var placementUuid: F4SUUID
    public private (set) var companyName: String
    
    public private (set) var documents: [F4SDocument]
    
    public init?(action: F4SAction, placement: F4STimelinePlacement, company: Company) {
        guard action.actionType == .uploadDocuments, let placementUuid = action.argument(name: F4SActionArgumentName.placementUuid)?.value.first else {
            return nil
        }
        self.placementUuid = placementUuid
        self.companyName = company.name.stripCompanySuffix()

        let documentTypeNames = action.argument(name: F4SActionArgumentName.documentType)?.value ?? []
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
