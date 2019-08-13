/// A minimal representation of the user before they have been identified by
/// their email address
public struct F4SAnonymousUser : Codable {
    public var vendorUuid: String
    public var clientType: String
    public var apnsEnvironment: String
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - vendorUuid: now called the installation uuid on the ios client, this is generated fresh for every install
    ///   - clientType: alway set to "ios" by the ios client
    ///   - apnsEnvironment: specifies the apple push notification environment
    public init(vendorUuid: F4SUUID, clientType: String, apnsEnvironment: String) {
        self.vendorUuid = vendorUuid
        self.clientType = clientType
        self.apnsEnvironment = apnsEnvironment
    }
}

extension F4SAnonymousUser {
    private enum CodingKeys : String, CodingKey {
        case vendorUuid = "vendor_uuid"
        case  clientType = "type"
        case apnsEnvironment = "env"
    }
}
