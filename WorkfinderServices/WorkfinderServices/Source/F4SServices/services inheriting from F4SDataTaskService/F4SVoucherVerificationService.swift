import Foundation
import WorkfinderCommon
import WorkfinderNetworking

public struct F4SVoucherValidationError : Codable {
    public var status: String?
}

public struct F4SVoucherValidation : Codable {
    public var status: String?
    public var errors: F4SVoucherValidationError?
}

public protocol F4SVoucherVerificationServiceProtocol {
    var apiName: String { get }
    func verify(completion: @escaping (F4SNetworkResult<F4SVoucherValidation>) -> ())
    func cancel()
}

public class F4SVoucherVerificationService : F4SDataTaskService {
    public let placementUuid: F4SUUID?
    public let voucherCode: F4SUUID
    
    public init(placementUuid: F4SUUID?, voucherCode: String) {
        self.placementUuid = placementUuid
        self.voucherCode = voucherCode
        let api = "voucher/\(voucherCode)"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: api)
    }
}

// MARK:- F4SVoucherVerificationServiceProtocol conformance
extension F4SVoucherVerificationService : F4SVoucherVerificationServiceProtocol {
    
    public func verify(completion: @escaping (F4SNetworkResult<F4SVoucherValidation>) -> ()) {
        var params = [String: String]()
        if let placementUuid = self.placementUuid { params = ["placement_uuid" : placementUuid] }
        let attempting = "Validate voucher code"
        beginSendRequest(verb: .put, objectToSend: params, attempting: attempting) { [weak self] (result) in
            self?.processResult(result, attempting: attempting, completion: completion)
        }
    }
}
