
public protocol WorkfinderEnvironmentConsistencyCheckerProtocol {
    func performChecksWithHardStop(completion: @escaping (Error?) -> Void)
}
