
public struct DeeplinkDispatchInfo {
    
    public enum Source {
        case deeplink
        case pushNotification
    }
    
    public enum ObjectType {
        case recommendation
        case project
        case application
    }
    
    public enum Action {
        case list
        case view(F4SUUID)
    }
    
    public var source: Source
    public var objectType: ObjectType
    public var action: Action
    
    public init(source: Source, objectType: ObjectType, action: Action) {
        self.source = source
        self.objectType = objectType
        self.action = action
    }
}
