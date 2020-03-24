import Foundation

public enum DocumentUploadState {
    case waiting
    case uploading(fraction: Float)
    case completed
    case cancelled
    case paused(fraction: Float)
    case failed(error: Error)
}

public typealias F4SVersionValidity = Bool

public protocol F4SDocumentUploaderDelegate : class {
    func documentUploader(_ uploader: F4SDocumentUploaderProtocol, didChangeState state: DocumentUploadState)
}

public protocol F4SDocumentUploaderProtocol : class {
    var delegate: F4SDocumentUploaderDelegate? { get set }
    var state: DocumentUploadState { get }
    func cancel()
    func resume()
}

public protocol EmailVerificationServiceProtocol {
    func cancel()
    
    func start(email: String,
               clientId: String,
               onSuccess: @escaping (_ email:String) -> Void,
               onFailure: @escaping (_ email:String, _ clientId:String, _ error:EmailSubmissionError) -> Void)
    
    func verifyWithCode(email: String, code: String, onSuccess: @escaping  ( _ email:String) -> Void, onFailure: @escaping (_ email:String, _ error:CodeValidationError) -> Void)
}

public protocol F4SRoleServiceProtocol {
    func getRoleForCompany(companyUuid: F4SUUID, roleUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SRoleJson>) -> ())
}

public protocol F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void)
}

public protocol F4SDeviceRegistrationServiceProtocol {
    func registerDevice(anonymousUser: F4SAnonymousUser, completion: @escaping ((F4SNetworkResult<F4SRegisterDeviceResult>) -> ()))
}

public protocol CompanyFavouritingServiceProtocol {
    var apiName: String { get }
    func favourite(companyUuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SShortlistJson>) -> Void)
    func unfavourite(shortlistUuid: String, completion: @escaping (F4SNetworkResult<F4SUUID>) -> Void)
}
public protocol F4SUserStatusServiceProtocol {
    var userStatus: F4SUserStatus? { get }
    func beginStatusUpdate()
    func getUserStatus(completion: @escaping (F4SNetworkResult<F4SUserStatus>) -> ())
}

public protocol F4SUserServiceProtocol : class {
    func updateUser(user: F4SUser, completion: @escaping (F4SNetworkResult<F4SUserModel>) -> ())
    func enablePushNotificationForUser(installationUuid: F4SUUID, withDeviceToken: String, completion: @escaping (_ result: F4SNetworkResult<F4SPushNotificationStatus>) -> ())
}

public protocol F4SAvailabilityServiceProtocol {
    func getAvailabilityForPlacement(completion: @escaping (F4SNetworkResult<[F4SAvailabilityPeriodJson]>) -> ())
    func patchAvailabilityForPlacement(availabilityPeriods: F4SAvailabilityPeriodsJson, completion: @escaping ((F4SNetworkDataResult) -> Void ))
}


public protocol F4SPlacementDocumentsServiceProtocol {
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
    func putDocuments(documents: F4SPutDocumentsJson, completion: @escaping ((F4SNetworkResult<F4SJSONBoolValue>) -> Void ))
}

public protocol F4SUserDocumentsServiceProtocol {
    func getDocuments(completion: @escaping (F4SNetworkResult<F4SGetDocumentJson>) -> ())
}

public protocol F4SRecommendationServiceProtocol : class {
    func fetch(completion: @escaping (F4SNetworkResult<[F4SRecommendation]>) -> ())
}

public protocol F4SCompanyServiceProtocol {
    func getCompany(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<CompanyJson>) -> ())
}
