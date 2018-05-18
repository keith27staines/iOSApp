//
//  F4SCompanyDocumentService.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation


public class F4SCompanyDocumentService {
    
    private var loaderQueue: DispatchQueue {
        return DispatchQueue(label: "loadDocuments", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    }
    
    
    public func requestDocuments(companyUuid: F4SUUID, documents: CompanyDocuments, completion: @escaping ((F4SNetworkResult<CompanyDocuments>) -> ())) {
        loaderQueue.async {
            sleep(1)
            DispatchQueue.main.async {
                let updatedDocs = documents.map { (document) -> CompanyDocument in
                    var doc = document
                    doc.status = CompanyDocument.Status.requested.rawValue
                    return doc
                } as CompanyDocuments
                let result = F4SNetworkResult.success(updatedDocs)
                completion(result)
            }
        }
        
    }
    
    public func getDocuments(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<CompanyDocuments>)->()) {
        loaderQueue.async {
            sleep(1)
            DispatchQueue.main.async {
                let documents = [
                    CompanyDocument(name: "Employer's Liability Insurance Certificate", status: "unrequested"),
                    CompanyDocument(name: "Safe Guarding Certificate", status: "requested"),
                    CompanyDocument(name: "Other document 1", status: "available"),
                    CompanyDocument(name: "Other document 2", status: "available"),
                    CompanyDocument(name: "Other document 3", status: "available")]
                
                completion(F4SNetworkResult.success(documents))
            }
        }
    }
}
