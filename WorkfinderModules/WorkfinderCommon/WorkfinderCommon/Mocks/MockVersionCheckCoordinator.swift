
import Foundation

public class MockVersionCheckCoordinator: VersionCheckCoordinatorProtocol {
    
    let versionIsOkay: Bool
    public var testVersionCheckWasCalled: (() -> Void)?
    
    public var versionCheckCompletion: ((F4SNetworkResult<F4SVersionValidity>) -> Void)?
    
    public var parentCoordinator: Coordinating?
    
    public var uuid: UUID = UUID()
    
    public var childCoordinators: [UUID : Coordinating] = [:]
    
    public func start() {
        let validity = F4SVersionValidity(booleanLiteral: versionIsOkay)
        let result = F4SNetworkResult.success(validity)
        DispatchQueue.main.async { [weak self] in
            self?.versionCheckCompletion?(result)
            self?.testVersionCheckWasCalled?()
        }
    }
    
    public init(versionIsOkay: Bool) {
        self.versionIsOkay = versionIsOkay
    }
}
