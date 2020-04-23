
public typealias PicklistsDictionary = [PicklistType: PicklistProtocol]

public protocol PicklistProtocol {
    var type: PicklistType { get }
    var items: [PicklistItemJson] { get }
    var title: String { get }
    var userInstruction: String { get }
    var maximumPicks: Int { get }
    var selectedItems: [PicklistItemJson] { get set }
    var itemSelectedSummary: String { get }
    func selectItem(_ item: PicklistItemJson)
    func deselectItem(_ item: PicklistItemJson)
    func fetchItems(completion: @escaping ((PicklistProtocol, Result<[PicklistItemJson],Error>)->Void) )
}
