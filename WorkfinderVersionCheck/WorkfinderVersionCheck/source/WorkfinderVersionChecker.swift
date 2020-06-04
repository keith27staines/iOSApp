
import UIKit
import WorkfinderCommon

let __appStoreLink = "itms-apps://itunes.apple.com/app/apple-store//id1196236194?mt=8"

protocol ForceUpdatePresenter: AnyObject {
    func gotoAppStore()
}

public class WorkfinderVersionChecker: WorkfinderVersionCheckerProtocol {
    let serverEnvironmentType: EnvironmentType
    let thisVersion: Version?
    var completion: ((Error?) -> Void)?
    var service: VersionCheckServiceProtocol
    var log: F4SAnalyticsAndDebugging?
    var lastCheck: Date
    let minimumIntervalBetweenChecks: TimeInterval = 5 * 60
    
    var timeSinceLastCheck: TimeInterval {
        return Date().timeIntervalSince(lastCheck)
    }
    
    var isTimeSinceLastCheckGreaterThanMinimum: Bool {
        timeSinceLastCheck > minimumIntervalBetweenChecks
    }
    
    init(serverEnvironmentType: EnvironmentType,
         currentVersion: String,
         versionCheckService: VersionCheckServiceProtocol,
         log: F4SAnalyticsAndDebugging? = nil) {
        self.service = versionCheckService
        self.thisVersion = Version(string: currentVersion)
        self.serverEnvironmentType = serverEnvironmentType
        lastCheck = Date().addingTimeInterval(-minimumIntervalBetweenChecks*2)
    }
    
    public convenience init(
            serverEnvironmentType: EnvironmentType,
            currentVersion: String,
            networkConfig: NetworkConfig,
            log: F4SAnalyticsAndDebugging) {
        let service = VersionCheckService(networkConfig: networkConfig)
        self.init(serverEnvironmentType: serverEnvironmentType,
                  currentVersion: currentVersion,
                  versionCheckService: service,
                  log: log)
    }
    
    public func performChecksWithHardStop(completion: @escaping (Error?) -> Void) {
        performEnvironmentCheckWithHardStop() {
            performVersionCheckWithHardStop(completion: completion)
        }
    }
    var environmentConsistencyCheckRequired: Bool = true
    
    func performEnvironmentCheckWithHardStop(completion: () -> Void) {
        guard environmentConsistencyCheckRequired else {
            completion()
            return
        }
        environmentConsistencyCheckRequired = false
        let localStore = LocalStore()
        guard let isFirstLaunchValue = localStore.value(key: .isFirstLaunch) as? Bool else {
            localStore.setValue(true, for: .isFirstLaunch)
            localStore.setValue(serverEnvironmentType.rawValue, for: .environment)
            completion()
            return
        }
        let localEnvironmentName = localStore.value(key: .environment) as? String ?? "unknown"
        let localEnvironmentType = EnvironmentType.init(rawValue: localEnvironmentName)
        guard localEnvironmentType != serverEnvironmentType
            else {
                completion()
                return
        }
        let window = UIApplication.shared.keyWindow!
        window.rootViewController = ForceEnvironmentSwitchViewController(
            serverEnvironment: serverEnvironmentType,
            localStoreEnvironment: localEnvironmentType)
        window.makeKeyAndVisible()
    }
    
    func performVersionCheckWithHardStop(completion: @escaping (Error?) -> Void) {
        guard isTimeSinceLastCheckGreaterThanMinimum else {
            completion(nil)
            return
        }
        self.completion = completion
        service.fetchMinimumVersion { [weak self] (result) in
            guard let self = self else { return }
            self.lastCheck = Date()
            print(self.isTimeSinceLastCheckGreaterThanMinimum)
            switch result {
            case .success(let versionJson):
                let minimumVersion = Version(string: versionJson.version)
                switch self.checkVersion(self.thisVersion, minimumVersion: minimumVersion) {
                case .good: completion(nil)
                case .bad: self.forceUpdate()
                case .undetermined:
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func checkVersion(_ actual: Version?, minimumVersion: Version?) -> VersionCheckResult {
        guard let actual = actual, let minimumVersion = minimumVersion  else { return .undetermined }
        return actual < minimumVersion ? .bad : .good
    }
    
    func forceUpdate() {
        let window = UIApplication.shared.keyWindow!
        window.rootViewController = ForceAppUpdateViewController(presenter: self)
        window.makeKeyAndVisible()
    }
}


extension WorkfinderVersionChecker: ForceUpdatePresenter {
    func gotoAppStore() {
        guard let url = URL(string: __appStoreLink), UIApplication.shared.canOpenURL(url)
            else { return }
        UIApplication.shared.open(url)

    }
}


