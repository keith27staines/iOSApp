
import Foundation
import WorkfinderCommon

public class AppInstallationLogic : AppInstallationLogicProtocol {
    
    let localStore: LocalStorageProtocol
    
    public init(localStore: LocalStorageProtocol) {
        self.localStore = localStore
    }
}
