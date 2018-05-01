//
//  F4SCompanyDocumentsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct CompanyDocument : Codable {
    public enum Status : String {
        case available
        case requested
        case unrequested
        case unavailable
    }
    var name: String
    var status: String
    var url: URL {
        return URL(string: "https://www.raspberrypi.org")!
    }
}

public typealias CompanyDocuments = [CompanyDocument]

protocol F4SCompanyDocumentsTableViewControllerDelegate {
    func companyDocumentsLoadAttemptCompleted(_ controller: F4SCompanyDocumentsTableViewController, success: Bool?, error: Error?, model: F4SCompanyDocumentsModel)
}

public class F4SCompanyDocumentsModel {
    
    public private (set) var availableDocuments: CompanyDocuments? = nil
    public private (set) var requestableDocuments: CompanyDocuments? = nil
    
    public let companyUuid: F4SUUID
    private var service: F4SCompanyDocumentService? = nil
    
    public init(companyUuid: F4SUUID) {
        self.companyUuid = companyUuid
    }
    
    public var numberOfSections: Int = 2
    
    public func rowsInSection(section: Int) -> Int {
        if section == 0 { return availableDocuments?.count ?? 0 }
        if section == 1 { return requestableDocuments?.count ?? 0}
        return 0
    }
    
    public func document(_ indexPath: IndexPath) -> CompanyDocument {
        if indexPath.section == 0 {
            return availableDocuments![indexPath.row]
        } else {
            return requestableDocuments![indexPath.row]
        }
    }
    
    public func requestDocuments(_ documents: CompanyDocuments, completion: @escaping ((F4SNetworkResult<CompanyDocuments>) -> ())) {
        service?.requestDocuments(companyUuid: companyUuid, documents: documents)  { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .error(_):
                    break
                case .success( let documents ):
                    for (i,document) in strongSelf.requestableDocuments!.enumerated() {
                        for doc in documents {
                            if doc.name == document.name {
                                strongSelf.requestableDocuments![i] = doc
                                break
                            }
                        }
                    }
                    break
                }
                completion(result)
            }
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
                strongSelf.availableDocuments = documents.filter({ (doc) -> Bool in
                    return doc.status == CompanyDocument.Status.available.rawValue
                })

                strongSelf.requestableDocuments = documents.filter({ (doc) -> Bool in
                    guard let status = CompanyDocument.Status(rawValue: doc.status) else {
                        return false
                    }
                    switch status {
                    case .available:
                        return false
                    case .requested:
                        return true
                    case .unrequested:
                        return true
                    case .unavailable:
                        return false
                    }
                })
            }
            completion(result)
        }
        self.service = service
    }
}
