
import WorkfinderCommon

public class LocalStoreMigrationsRunner {
    
    private let migrations: [Migrator] = [
        Migrate_v2_to_v3()
    ]
    
    public func run() {
        migrations.forEach { (migrator) in
            migrator.performMigration()
        }
        updateAppVersionInLocalStore()
    }
    
    func updateAppVersionInLocalStore() {
        let defaults = UserDefaults.standard
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "app version not specified in bundle"
        defaults.setValue(version, for: LocalStore.Key.appVersion)
    }
}



