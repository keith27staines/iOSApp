
import UIKit
import WorkfinderCommon
import WorkfinderUI

let __appStoreLink = "itms-apps://itunes.apple.com/app/apple-store//id1196236194?mt=8"

protocol ForceUpdatePresenter: AnyObject {
    func gotoAppStore()
}

public class WorkfinderEnvironmentConsistencyChecker: WorkfinderEnvironmentConsistencyCheckerProtocol {
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
            // environment consistency checks only need to be run once
            completion()
            return
        }
        environmentConsistencyCheckRequired = false
        let localStore = LocalStore()
        // Has an environment been set yet?
        guard let localEnvironmentName = localStore.value(key: .environment) as? String else {
            // No local environment has been established so the server cannot be inconsistent with it
            // Just set the local environment to match the server and return
            localStore.setValue(serverEnvironmentType.rawValue, for: .environment)
            completion()
            return
        }
        // Does the local environment match the server environment?
        let localEnvironmentType = EnvironmentType.init(rawValue: localEnvironmentName)
        guard localEnvironmentType != serverEnvironmentType
        else {
            // local environment (from last run) matches the server environment
            // therefore there is no inconsistency
            completion()
            return
        }
        
        // The local environment and the server environment don't match
        // Therefore, we cannot let the app run
        guard let window = UIApplication.shared.firstKeyWindow else {
            completion()
            return
        }
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
                let minimumVersion = Version(string: versionJson.min_version)
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
        guard let window = UIApplication.shared.firstKeyWindow else { return }
        window.rootViewController = ForceAppUpdateViewController(presenter: self)
        window.makeKeyAndVisible()
    }
}


extension WorkfinderEnvironmentConsistencyChecker: ForceUpdatePresenter {
    func gotoAppStore() {
        guard let url = URL(string: __appStoreLink), UIApplication.shared.canOpenURL(url)
            else { return }
        UIApplication.shared.open(url)

    }
}


