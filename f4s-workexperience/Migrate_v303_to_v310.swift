//
//import WorkfinderCommon
//
//final class Migrate_v3_0_3__to__v3_1_0: MigratorBase {
//    
//    init() {
//        super.init(
//            updatesFromStoreVersion: LocalStoreVersion.v3_0_1,
//            updatesToStoreVersion: LocalStoreVersion.v3_1_0)
//    }
//    
//    override func performMigration(localStore: LocalStorageProtocol) -> MigrationResult {
//        guard
//            let storeVersionString = localStore.value(key: .localStoreVersion) as? String,
//            let storeVersion = LocalStoreVersion(rawValue: storeVersionString)
//            else {
//                return .notNeeded(updatesToStoreVersion)
//        }
//        guard storeVersion == updatesFromStoreVersion else {
//            return .error(storeVersion, MigrationError.storeAtUnexpectedVersion)
//        }
//        guard
//            let selected = localStore.value(key: .picklistsSelectedValuesData) as? [Int: PicklistProtocol]
//            else {
//                return .notNeeded(updatesToStoreVersion)
//        }
//        /* This is the order from current production release 3.0.3
//        0: case year
//        1: case subject
//        2: case institutions
//        3: case placementType
//        4: case project
//        5: case motivation
//        6: case availabilityPeriod
//        7: case duration
//        8: case experience
//        9: case attributes
//        10: case skills
//        */
//        
//        /* This is the order from production release 3.1.0
//         0: case year
//         1: case subject
//         2: case institutions
//         3: case placementType
//         4: case project
//         5: case motivation
//         6: case availabilityPeriod
//         7: case duration
//         8: case experience
//         9: case attributes
//         10: case skills
//         */
//        var migrated = [PicklistType: PicklistProtocol]()
//        migrated[.year] = selected[0]
//        migrated[.subject] = selected[1]
//        migrated[.institutions] = selected[2]
//        migrated[.placementType] = selected[3]
//        migrated[.project] = selected[4]
//        migrated[.motivation] = selected[5]
//        migrated[.availabilityPeriod] = selected[6]
//        migrated[.duration] = selected[7]
//        migrated[.experience] = selected[8]
//        migrated[.attributes] = selected[9]
//        migrated[.skills] = selected[10]
//        
//        localStore.setValue(migrated, for: .picklistsSelectedValuesData)
//        return .performed(updatesToStoreVersion)
//    }
//}
