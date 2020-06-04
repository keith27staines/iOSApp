
import Foundation
import WorkfinderCommon

protocol Migrator: CustomStringConvertible {
    var updatesFromStoreVersion: LocalStoreVersion { get }
    var updatesToStoreVersion: LocalStoreVersion { get }
    func performMigration(localStore: LocalStorageProtocol) -> MigrationResult
}

enum MigrationResult {
    case notNeeded(LocalStoreVersion)
    case performed(LocalStoreVersion)
    case error(LocalStoreVersion, Error)
}

class MigratorBase: Migrator {

    let updatesFromStoreVersion: LocalStoreVersion
    let updatesToStoreVersion: LocalStoreVersion
    var description: String {
        "migrate from \(updatesFromStoreVersion) to \(updatesToStoreVersion)"
    }
    
    init(updatesFromStoreVersion: LocalStoreVersion,
         updatesToStoreVersion: LocalStoreVersion){
        self.updatesFromStoreVersion = updatesFromStoreVersion
        self.updatesToStoreVersion = updatesToStoreVersion
    }
    
    func performMigration(localStore: LocalStorageProtocol) -> MigrationResult {fatalError("Must override")}

}
