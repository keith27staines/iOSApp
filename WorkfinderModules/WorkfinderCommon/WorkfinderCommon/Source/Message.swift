import Foundation

public struct Message : MessageProtocol {
    public var isRead: Bool?
    public var uuid: String = UUID().uuidString
    public let senderId: String
    public var sentDate: Date?
    public var receivedDate: Date?
    public var readDate: Date?
    public var text: String?
    
    public init(senderId: String) {
        self.senderId = senderId
    }
}

