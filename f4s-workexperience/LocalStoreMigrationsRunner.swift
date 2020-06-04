
import WorkfinderCommon

enum LocalStoreVersion: String {
    case unrecognised
    case v2_all     // any v2 (or v1) version migrates to v3_0_1
    case v3_0_1     // first v3 release to go live on appstore
    
    /*
     Need to add a new migration?
     1. Add a new LocalStoreVersion to this enum
     2. Write a migrator (conforming to `Migrator` and preferably inheriting from `MigratorBase` (which guarentees conformance). The new migrator should perform all the operations required to upgrade the local store to whatever new data models you are introducing, or old models you are modifying.
     3. Append the new migrator to the `migrations` array in `LocalStoreMigrationsRunner`
     */
}

class LocalStoreMigrationsRunner {
    
    private let migrations: [Migrator] = [
        Migrate_v2_all__to__v3_0_1()
    ]
    
    public func run(localStore: LocalStorageProtocol) {
        var latestStoreVersion = LocalStoreVersion.unrecognised
        migrations.forEach { (migrator) in
            switch migrator.performMigration(localStore: localStore) {
            case .notNeeded(let version):
                latestStoreVersion = version
            case .performed(let version):
                latestStoreVersion = version
            case .error(let version, let error):
                latestStoreVersion = version
                assertionFailure("Migrator error: \(migrator.description) \n\(error)")
            }
            localStore.setValue(latestStoreVersion.rawValue, for: .localStoreVersion)
        }
        updateAppVersionInLocalStore()
        localStore.setValue(latestStoreVersion, for: .localStoreVersion)
    }
    
    func updateAppVersionInLocalStore() {
        let defaults = UserDefaults.standard
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "app version not specified in bundle"
        defaults.setValue(version, for: LocalStore.Key.appVersion)
    }
}



