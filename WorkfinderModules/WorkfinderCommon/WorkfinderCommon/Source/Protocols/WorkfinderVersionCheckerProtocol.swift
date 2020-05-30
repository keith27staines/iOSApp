
public protocol WorkfinderVersionCheckerProtocol {
    func performChecksWithHardStop(completion: @escaping (Error?) -> Void)
}
