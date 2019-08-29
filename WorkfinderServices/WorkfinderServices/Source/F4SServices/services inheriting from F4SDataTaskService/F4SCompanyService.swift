import WorkfinderCommon
import WorkfinderNetworking

public struct F4SCompanyJson : Codable {
    public var linkedInUrlString: String?
    public var duedilUrlString: String?
    public var linkedinUrl: URL? {
        return URL(string: self.linkedInUrlString ?? "")
    }
    public var duedilUrl: URL? {
        return URL(string: self.duedilUrlString ?? "")
    }
    public init() {
    }
}

extension F4SCompanyJson {
    private enum CodingKeys : String, CodingKey {
        case linkedInUrlString = "linkedin_url"
        case duedilUrlString = "duedil_url"
    }
}

public protocol F4SCompanyServiceProtocol {
    func getCompany(uuid: F4SUUID, completion: @escaping (F4SNetworkResult<F4SCompanyJson>) -> ())
}

public class F4SCompanyService: F4SDataTaskService, F4SCompanyServiceProtocol {

    public init() {
        let apiName = "company"
        super.init(baseURLString: NetworkConfig.workfinderApiV2, apiName: apiName)
    }

    public func getCompany(uuid: F4SUUID, completion: @escaping
        (F4SNetworkResult<F4SCompanyJson>) -> ()) {
        relativeUrlString = uuid
        beginGetRequest(attempting: "Get company detail", completion: completion)
    }
}












