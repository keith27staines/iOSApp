import Foundation

public struct F4SGetCompanyDocuments: Codable {
    public var companyUuid: F4SUUID?
    public var documents: F4SCompanyDocuments?
    public var possibleDocumentTypes: [String]?
    public init(companyUuid: String?,
                documents: F4SCompanyDocuments?,
                possibleDocumentTypes: [String]?) {
        self.companyUuid = companyUuid
        self.documents = documents
        self.possibleDocumentTypes = possibleDocumentTypes
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

public struct F4SCompanyDocument : Codable {
    
    public enum State : String, Codable {
        case available
        case requested
        case unrequested
        case unavailable
    }
    
    // Encodable properties
    public var uuid: F4SUUID?
    public var name: String
    public var state: State
    public var docType: String?
    public var requestedCount: Int?
    public var urlString: String?
    
    public var isRequestable: Bool {
        return state == F4SCompanyDocument.State.unrequested ||
            state == F4SCompanyDocument.State.requested
    }
    
    public var isViewable: Bool {
        return state == .available && url != nil
    }
    
    // Non-encodable properties
    public var userIsRequesting: Bool = false
    public var url: URL? {
        guard let urlString = urlString else {
            return nil
        }
        return URL(string: urlString)
    }
    
    public var providedNameOrDefaultName: String {
        return name.isEmpty ? F4SCompanyDocument.defaultNameForType(type: docType) : name
    }
    public init(documentType: String) {
        self.docType = documentType
        self.state = .unrequested
        self.name = F4SCompanyDocument.defaultNameForType(type: documentType)
        self.requestedCount = 0
        self.urlString = nil
    }
    
    public static func defaultNameForType(type: String?) -> String {
        switch type{
        case "ELC":
            return "Employer's liability certificate"
        case "SGC":
            return "Safeguarding certificate"
        default:
            return type ?? "unknown"
        }
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
