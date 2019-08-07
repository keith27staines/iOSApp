/// F4SUUIDDictionary provides a way of creating a JSON dictionary of the form
/// {
///    "uuid": uuid
/// }
/// This type of dictionary is required as a sub object for the user's partners
/// when constructing a JSON representation of the user
public struct F4SUUIDDictionary : Codable {
    public var uuid: F4SUUID
    public init(uuid: F4SUUID) {
        self.uuid = uuid
    }
}
