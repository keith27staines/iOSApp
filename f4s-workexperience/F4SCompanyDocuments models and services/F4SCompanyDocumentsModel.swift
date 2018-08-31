//
//  F4SCompanyDocumentsModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 23/04/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import Foundation

public struct F4SCompanyDocument : Codable {
    
    public enum State : String, Codable {
        case available
        case requested
        case unrequested
        case unavailable
    }
    
    // Encodable properties
    var uuid: F4SUUID?
    var name: String
    var state: State
    var docType: String?
    var requestedCount: Int?
    var urlString: String?
    
    // Non-encodable properties
    var userIsRequesting: Bool = false
    var url: URL? {
        guard let urlString = urlString else {
            return nil
        }
        return URL(string: urlString)
    }
    
    var nameOrType: String {
        return name.isEmpty ? docType ?? "unknown" : name
    }
    public init(documentType: String) {
        self.docType = documentType
        self.state = .unrequested
        self.name = ""
        self.requestedCount = 0
        self.urlString = nil
    }
    
    public init(uuid: F4SUUID, name: String, status: State, docType: String, requestedCount: Int? = 0, urlString: String? = nil) {
        self.uuid = uuid
        self.name = name
        self.state = status
        self.requestedCount = requestedCount
        self.urlString = urlString
        self.docType = docType
    }


}

extension F4SCompanyDocument {

    private enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case state
        case docType = "doc_type"
        case requestedCount = "request_count"
        case urlString = "url"
    }
}

public struct F4SGetCompanyDocuments: Decodable {
    public var companyUuid: F4SUUID?
    public var documents: F4SCompanyDocuments?
    public var possibleDocumentTypes: [String]?
    
    static func defaultNameForType(type: String) -> String {
        switch type{
        case "ELC":
            return "Employer's liability certificate"
        case "SGC":
            return "Safeguarding certificate"
        default:
            return type
        }
    }
}

extension F4SGetCompanyDocuments {
    private enum CodingKeys: String, CodingKey {
        case companyUuid = "uuid"
        case documents = "requested_documents"
        case possibleDocumentTypes = "possible_doc_types"
    }
}

public typealias F4SCompanyDocuments = [F4SCompanyDocument]

public class F4SCompanyDocumentsModel {

    public let companyUuid: F4SUUID
    
    public private (set) var documents: F4SCompanyDocuments = F4SCompanyDocuments()
    
    public var availableDocuments: F4SCompanyDocuments {
        return documents.filter({ (document) -> Bool in
            document.state == F4SCompanyDocument.State.available
        })
    }
    
    public var requestableDocuments: F4SCompanyDocuments {
        return documents.filter({ (document) -> Bool in
            [F4SCompanyDocument.State.unrequested, F4SCompanyDocument.State.requested].contains(document.state)
        })
    }
    
    public var unavailableDocuments: F4SCompanyDocuments {
        return documents.filter({ (document) -> Bool in
            document.state == F4SCompanyDocument.State.unavailable
        })
    }
    
    public init(companyUuid: F4SUUID) {
        self.companyUuid = companyUuid
    }
    
    public var numberOfSections: Int = 3
    
    public func rowsInSection(section: Int) -> Int {
        if section == 0 { return availableDocuments.count }
        if section == 1 { return requestableDocuments.count }
        return 0
    }
    
    public func updateUserIsRequestingState(document: F4SCompanyDocument, isRequesting: Bool) -> F4SCompanyDocument? {
        for (i, doc) in documents.enumerated() {
            if doc.docType == document.docType {
                documents[i].userIsRequesting = isRequesting
                return documents[i]
            }
        }
        return nil
    }
    
    public func document(_ indexPath: IndexPath) -> F4SCompanyDocument? {
        switch indexPath.section {
        case 0:
            return availableDocuments[indexPath.row]
        case 1:
            return requestableDocuments[indexPath.row]
        case 2:
            return unavailableDocuments[indexPath.row]
        default:
            return nil
        }
    }
    
    public func requestDocumentsFromCompany(completion: @escaping (F4SNetworkResult<Bool>) -> ()) {
        var requestingDocuments = F4SCompanyDocuments()
        for document in documents {
            if document.userIsRequesting {
                requestingDocuments.append(document)
            }
        }
        guard requestingDocuments.count > 0 else {
            completion(F4SNetworkResult.success(true))
            return
        }
        service.requestDocuments(companyUuid: companyUuid, documents: requestingDocuments) { (result) in
            completion(result)
        }
    }
    
    lazy var service: F4SCompanyDocumentService = {
        return F4SCompanyDocumentService()
    }()
    
    public func getDocuments(age: Int, completion: @escaping (F4SNetworkResult<F4SCompanyDocuments>)->()) {
        service.getDocuments(companyUuid: companyUuid) { [weak self] result in
            DispatchQueue.main.async {
                guard let this = self else { return }
                switch result {
                case .error(let error):
                    completion(F4SNetworkResult.error(error))
                case .success( let getDocumentsStructure ):
                    let documents = this.buildDocumentsFromGetDocumentsResult(age: age, result: getDocumentsStructure)
                    this.documents = documents
                    completion(F4SNetworkResult.success(documents))
                }
            }
        }
    }
    
    private func buildDocumentsFromGetDocumentsResult(age: Int, result: F4SGetCompanyDocuments) -> F4SCompanyDocuments {
        var documents = [F4SCompanyDocument]()
        guard let documentTypes = result.possibleDocumentTypes else {
            return documents
        }
        
        // Create array of placeholder documents from the possible document types
        let placeholderDocuments: [F4SCompanyDocument] = documentTypes.map({ (docType) -> F4SCompanyDocument in
            return F4SCompanyDocument(documentType: docType)
        })
        
        // Populate the placeholders with real documents that match the document type of the placeholder
        for placeholder in placeholderDocuments {
            if let matchingDocument = result.documents?.filter({ (possibleMatch) -> Bool in
                possibleMatch.docType == placeholder.docType
            }).first {
                documents.append(matchingDocument)
            } else {
                documents.append(placeholder)
            }
        }
        // filter out SGC document if user is 18 or older
        if age >= 18 {
            documents = documents.filter({ (document) -> Bool in
                return (document.docType != "SGC")
            })
        }
        return documents
    }
}
