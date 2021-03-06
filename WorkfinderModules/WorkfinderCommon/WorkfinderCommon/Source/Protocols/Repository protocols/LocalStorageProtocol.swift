
/// Defines the interface for a locally persisting dictionary where they keys are elements of an enum
public protocol LocalStorageProtocol : AnyObject {
    func value(key: LocalStore.Key) -> Any?
    func setValue(_ value: Any?, for key: LocalStore.Key)
    func resetStore()
}
