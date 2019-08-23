import Foundation

public struct F4SGetDocumentJson : Codable {
    public let uuid: F4SUUID?
    public let documents: [F4SDocument]?
}

public struct F4SPutDocumentsJson : Codable {
    public let documents: [F4SDocument]?
    public init(documents: [F4SDocument]?) {
        self.documents = documents
    }
}

public enum F4SUploadableDocumentType : String, CaseIterable, Codable {
    case cv
    case other
    
    public var name: String {
        switch self {
        case .cv:
            return "CV"
        case .other:
            return "Other"
        }
    }
}

public class F4SDocument : Codable {
    
    static public let defaultTitle = "untitled"
    
    /// F4S uuid of the document
    public var uuid: F4SUUID?
    
    public var uuidForiOSFileSystem: String = UUID().uuidString
    
    /// The (perhaps temporary) url where the document is currently located on this device, prior to upload
    public var localUrlString: String? = nil
    
    /// the remote url of the document
    public var remoteUrlString: String?
    
    public var documentServerUrlString: String?
    
    public var viewableUrlString: String? {
        if isOptionalUrlStringOpenable(documentServerUrlString) { return documentServerUrlString}
        if isOptionalUrlStringOpenable(remoteUrlString) { return remoteUrlString }
        return localUrlString // local url will be viewable if it exists
    }
    
    
    /// The url where the document can be viewed (might be local, might be remote)
    public var viewableUrl: URL? {
        guard let urlString = viewableUrlString else { return nil }
        return URL(string: urlString)
    }
    
    private func isOptionalUrlStringOpenable(_ urlString: String?) -> Bool {
        guard
            let string = urlString,
            string.isEmpty == false,
            let url = URL(string: string),
            UIApplication.shared.canOpenURL(url) else { return false }
        return true
    }
    
    public var isViewableOnUrl: Bool {
        guard let url = viewableUrl, UIApplication.shared.canOpenURL(url) else { return false }
        return true
    }
    
    public var type: F4SUploadableDocumentType = .other
    public var name: String?
    public var data: Data? = nil
    
    public var hasValidRemoteUrl: Bool {
        guard let remoteUrl = self.remoteUrl else {
            return false
        }
        return UIApplication.shared.canOpenURL(remoteUrl)
    }
    
    /// The remote url where the document should be available
    public var remoteUrl: URL? {
        guard let remoteUrlString = remoteUrlString else { return nil }
        return URL(string: remoteUrlString)
    }
    
    public var isReadyForUpload: Bool {
        if isUploaded { return false }
        if let realData = data, realData.count > 0 { return true }
        guard let remoteUrlString = remoteUrlString,
            let url = URL(string: remoteUrlString),
            UIApplication.shared.canOpenURL(url) else {
                return false
        }
        return true
    }
    
    public var isUploaded: Bool = false
    
    public var defaultName: String {
        return "My \(type)"
    }
    
    /// Initializes a new instance
    /// - parameter uuid: The uuid of the url linking to the document
    /// - parameter urlString: The absolute string representation of the url where the document is permantently stored
    /// - parameter type: Describes the type of document
    /// - parameter name: The name of the document if it has one
    public init(uuid: F4SUUID? = nil,
                urlString: String? = nil,
                type: F4SUploadableDocumentType = .other,
                name: String? = nil) {
        self.uuid = uuid
        self.remoteUrlString = urlString
        self.type = type
        self.name = name ?? type.name
        self.data = nil
    }
}

extension F4SDocument {
    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case documentServerUrlString = "document"
        case remoteUrlString = "url"
        case type = "doc_type"
        case name = "title"
    }
}
