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
    
    public func getDocuments(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<CompanyDocuments>)->()) {
        loaderQueue.async {
            sleep(1)
            DispatchQueue.main.async {
                let documents = [
                    CompanyDocument(name: "Employer's Liability Insurance"),
                    CompanyDocument(name: "Safe Guarding Certificate"),
                    CompanyDocument(name: "Other document 1"),
                    CompanyDocument(name: "Other document 2"),
                    CompanyDocument(name: "Other document 3")]
                
                completion(F4SNetworkResult.success(documents))
            }
        }
    }
}
