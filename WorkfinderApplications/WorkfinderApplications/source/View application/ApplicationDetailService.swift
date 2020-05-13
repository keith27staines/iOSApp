import WorkfinderCommon

protocol ApplicationDetailServiceProtocol: AnyObject {
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<ApplicationDetail,Error>)-> Void)
}

class ApplicationDetailService: ApplicationDetailServiceProtocol {
    func fetchApplicationDetail(application: Application, completion: @escaping (Result<ApplicationDetail,Error>)-> Void) {
        completion(Result<ApplicationDetail,Error>.success(application))
    }
}
