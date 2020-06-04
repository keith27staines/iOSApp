
import WorkfinderCommon

protocol Migrator {
    var updatesFromStoreVersion: String { get }
    var updatesToStoreVersion: String { get }
    func performMigration()
}

class MigratorBase: Migrator {
    
    let store = UserDefaults.standard
    let updatesFromStoreVersion: String
    let updatesToStoreVersion: String
    
    init(updatesFromStoreVersion: String, updatesToStoreVersion: String) {
        self.updatesFromStoreVersion = updatesFromStoreVersion
        self.updatesToStoreVersion = updatesToStoreVersion
    }
    
    func performMigration() { }
    
    func updateLocalStoreVersion(string: String) {
        store.setValue(updatesToStoreVersion, for: .localStoreVersion)
    }
    
}
