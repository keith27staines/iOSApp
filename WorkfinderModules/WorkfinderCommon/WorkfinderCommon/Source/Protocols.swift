import Foundation



public protocol F4SDatabaseDownloadManagerProtocol : class {
    var localDatabaseDatestamp: Date? { get }
    func start()
    func registerObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func removeObserver(_ observer: F4SCompanyDatabaseAvailabilityObserving)
    func ageOfLocalDatabase() -> TimeInterval
    func isLocalDatabaseAvailable() -> Bool
}

public protocol F4SCompanyDatabaseAvailabilityObserving : class {
    func newStagedDatabaseIsAvailable(url: URL)
    func newDatabaseIsDownloading(progress: Double)
}

public protocol AppInstallationUuidLogicProtocol : class {
    var registeredInstallationUuid: F4SUUID? { get }
    func ensureDeviceIsRegistered(completion: @escaping (F4SNetworkResult<F4SRegisterDeviceResult>)->())
}

public typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

public struct PersonViewData {
    public var uuid: String? = nil
    public var firstName: String? = nil
    public var lastName: String? = nil
    public var bio: String? = nil
    public var role: String? = nil
    public var imageName: String? = nil
    
    public var fullName: String { return "\(firstName ?? "") \(lastName ?? "")" }
    public var fullNameAndRole: String { return "\(fullName), \(role ?? "")"}
    public var linkedInUrl: String? = "https://www.bbc.co.uk"
    public var islinkedInHidden: Bool {
        return linkedInUrl == nil
    }
    
    public init(
        uuid: F4SUUID? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        bio: String? = nil,
        role: String? = nil,
        imageName: String? = nil,
        linkedInUrl: String? = nil) {
        
    }
}
