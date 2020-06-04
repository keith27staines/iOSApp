
import WorkfinderCommon
import KeychainSwift

class Migrate_v2_to_v3: MigratorBase {
    
    init() {
        super.init(
            updatesFromStoreVersion: "v2",
            updatesToStoreVersion: "v2")
    }
    
    override func performMigration() {
        guard store.value(key: LocalStore.Key.appVersion) == nil else { return }
        deleteV2KeysIfNecessary()
    }
    
    private func deleteV2KeysIfNecessary() {
        
        store.dictionaryRepresentation().forEach { (item) in
            store.removeObject(forKey: item.key)
        }
        KeychainSwift().clear()
    }
}
