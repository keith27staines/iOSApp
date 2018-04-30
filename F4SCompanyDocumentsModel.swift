//
//  F4SCompanyDocumentsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct CompanyDocument : Codable {
    var name: String
    var url: URL {
        return URL(string: "https://www.raspberrypi.org")!
    }
}

public typealias CompanyDocuments = [CompanyDocument]

protocol F4SCompanyDocumentsTableViewControllerDelegate {
    func companyDocumentsLoadAttemptCompleted(_ controller: F4SCompanyDocumentsTableViewController, success: Bool?, error: Error?, model: F4SCompanyDocumentsModel)
}

public class F4SCompanyDocumentsModel {
    
    public private (set) var documents: CompanyDocuments? = nil
    public let companyUuid: F4SUUID
    private var service: F4SCompanyDocumentService? = nil
    
    public init(companyUuid: F4SUUID) {
        self.companyUuid = companyUuid
    }
    
    public var numberOfSections: Int = 2
    
    public func rowsInSection(section: Int) -> Int {
        if section == 0 { return  documents?.count ?? 0 }
        if section == 1 { return unrequestedDocuments.count }
        return 0
    }
    
    public func document(_ indexPath: IndexPath) -> CompanyDocument {
        if indexPath.section == 0 {
            return documents![indexPath.row]
        } else {
            return unrequestedDocuments[indexPath.row]
        }
    }
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<CompanyDocuments>)->()) {
        let service = F4SCompanyDocumentService()
        service.getDocuments(companyUuid: companyUuid) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                break
            case .success( let documents ):
                strongSelf.documents = documents
                var importantDocuments = strongSelf.unrequestedDocuments
                for document in documents {
                    importantDocuments = importantDocuments.filter({ (importantDocument) -> Bool in
                        importantDocument.name != document.name
                    })
                }
                strongSelf.unrequestedDocuments = importantDocuments
            }
            completion(result)
        }
        self.service = service
    }
    
    var requestableDocuments: CompanyDocuments {
        let elc = CompanyDocument(name: "Employer's Liability Insurance Certificate")
        let sgc = CompanyDocument(name: "Safe Guarding Certificate")
        return [elc,sgc]
    }
    
    lazy var unrequestedDocuments: CompanyDocuments = {
        return requestableDocuments
    }()
}
