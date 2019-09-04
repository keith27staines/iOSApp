import Foundation

public protocol F4STemplateServiceProtocol {
    func getTemplates(completion: @escaping (F4SNetworkResult<[F4STemplate]>) -> Void)
}
