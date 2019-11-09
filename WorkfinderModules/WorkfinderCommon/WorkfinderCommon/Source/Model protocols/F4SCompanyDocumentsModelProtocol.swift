
public protocol F4SCompanyDocumentsModelProtocol: class {
    var documents: F4SCompanyDocuments { get }
    var availableDocuments: F4SCompanyDocuments { get }
    var requestableDocuments: F4SCompanyDocuments { get }
    var unavailableDocuments: F4SCompanyDocuments { get }
    func rowsInSection(section: Int) -> Int
    func updateUserIsRequestingState(document: F4SCompanyDocument, isRequesting: Bool) -> F4SCompanyDocument?
    func document(_ indexPath: IndexPath) -> F4SCompanyDocument?
    func getDocuments(age: Int, completion: @escaping (F4SNetworkResult<F4SCompanyDocuments>)->())
    func requestDocumentsFromCompany(completion: @escaping (F4SNetworkResult<F4SJSONBoolValue>) -> ())
}
