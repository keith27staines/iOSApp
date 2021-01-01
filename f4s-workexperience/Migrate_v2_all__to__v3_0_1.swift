
import WorkfinderCommon
import KeychainSwift

final class Migrate_v2_all__to__v3_0_1: MigratorBase {
    
    init() {
        super.init(
            updatesFromStoreVersion: LocalStoreVersion.v2_all,
            updatesToStoreVersion: LocalStoreVersion.v3_0_1)
    }
    
    override func performMigration(localStore: LocalStorageProtocol) -> MigrationResult {
        guard localStore.value(key: LocalStore.Key.appVersion) == nil else {
            let storeVersionString = localStore.value(key: .localStoreVersion) as? String ?? ""
            let storeVersion = LocalStoreVersion(rawValue: storeVersionString) ?? updatesToStoreVersion
            return .notNeeded(storeVersion)
        }
        // There is no way to migrate v2 to v3,
        // so delete all data and start afresh
        deleteAllData()
        return .performed(updatesToStoreVersion)
    }
    
    private func deleteAllData() {
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().forEach { (item) in
            defaults.removeObject(forKey: item.key)
        }
        KeychainSwift().clear()
    }
}
