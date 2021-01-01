
import WorkfinderCommon

final class Migrate_v3_0_1_to__v3_2_0: MigratorBase {
    
    init() {
        super.init(
            updatesFromStoreVersion: LocalStoreVersion.v3_0_1,
            updatesToStoreVersion: LocalStoreVersion.v3_2_0)
    }
    
    override func performMigration(localStore: LocalStorageProtocol) -> MigrationResult {
        guard
            let storeVersionString = localStore.value(key: .localStoreVersion) as? String,
            let storeVersion = LocalStoreVersion(rawValue: storeVersionString)
        else {
            return .notNeeded(updatesToStoreVersion)
        }
        guard storeVersion != updatesToStoreVersion
        else {
            return .notNeeded(updatesToStoreVersion)
        }
        
        guard storeVersion == updatesFromStoreVersion
        else {
            return .error(storeVersion, MigrationError.storeAtUnexpectedVersion)
        }
        
        // In 3_0_1, we used `isFirstLaunch` as a proxy for requiring onboarding
        // From 3_2_0, we are using the specific flag `isOnboardingRequired`
        guard
            let isFirstUse = (localStore.value(key: .isFirstLaunch) as? Bool),
            isFirstUse == false
        else { return .notNeeded(updatesToStoreVersion) }
        
        localStore.setValue(false, for: .isOnboardingRequired)
       
        return .performed(updatesToStoreVersion)
    }
}
