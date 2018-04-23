//
//  F4SCompanyDocumentsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct CompanyDocument : Encodable, Decodable {
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
    
    public init(companyUuid: F4SUUID) {
        self.companyUuid = companyUuid
    }
    
    private var loaderQueue: DispatchQueue {
        return DispatchQueue(label: "loadDocuments", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    }
    
    public func document(_ indexPath: IndexPath) -> CompanyDocument {
        return documents![indexPath.row]
    }
    
    public func loadDocuments(completion: @escaping (F4SNetworkResult<CompanyDocuments>)->()) {
        loaderQueue.async { [weak self] in
            sleep(1)
            
            DispatchQueue.main.async {
                // self?.documents = CompanyDocuments()
                self?.documents = [
                    CompanyDocument(name: "Employer's Liability Insurance"),
                    CompanyDocument(name: "Safe Guarding Certificate"),
                    CompanyDocument(name: "Other document 1"),
                    CompanyDocument(name: "Other document 2"),
                    CompanyDocument(name: "Other document 3")]

                completion(F4SNetworkResult.success(self!.documents!))
            }
        }
    }
}
