
import Foundation
import KeychainSwift
import WorkfinderCommon

extension F4SUser {
    public static func dataFixMoveUUIDFromKeychainToUserDefaults() {
        let keychain = KeychainSwift()
        guard let uuid = keychain.get(UserDefaultsKeys.userUuid) else { return }
        UserDefaults.standard.setValue(uuid, forKey: UserDefaultsKeys.userUuid)
        KeychainSwift().delete(UserDefaultsKeys.userUuid)
    }
}

