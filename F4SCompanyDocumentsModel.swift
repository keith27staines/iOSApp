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
    
    public func document(_ indexPath: IndexPath) -> CompanyDocument {
        return documents![indexPath.row]
    }
    
    public func getDocuments(completion: @escaping (F4SNetworkResult<CompanyDocuments>)->()) {
        let service = F4SCompanyDocumentService()
        service.getDocuments(companyUuid: companyUuid, completion: completion)
        self.service = service
    }
}
