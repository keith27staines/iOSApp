public struct F4SCompanyDatabaseMetaData : Codable {
    public var created: Date?
    public var urlString: String?
    public var errors: F4SJSONValue?
}

extension F4SCompanyDatabaseMetaData {
    private enum CodingKeys : String, CodingKey {
        case created
        case urlString = "url"
        case errors
    }
}
