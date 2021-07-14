
public typealias PicklistsDictionary = [PicklistType: PicklistProtocol]

public protocol PicklistProtocol: AnyObject {
    var isLoaded: Bool { get }
    var isPopulated: Bool { get }
    var otherItem: PicklistItemJson? { get }
    var type: PicklistType { get }
    var items: [PicklistItemJson] { get }
    var maximumPicks: Int { get }
    var selectedItems: [PicklistItemJson] { get }
    var previousSelectedItemsBeforeDeselectAll: [PicklistItemJson] { get }
    var itemSelectedSummary: String { get }
    var isOtherSelected: Bool { get }
    func updateSelectedTextValue(_ text: String)
    var preselectedUuids: [F4SUUID] { get set }
    func selectItem(_ item: PicklistItemJson)
    func selectItems(_ items: [PicklistItemJson])
    func deselectItem(_ item: PicklistItemJson)
    func deselectAll()
    func fetchItems(completion: @escaping ((PicklistProtocol, Result<[PicklistItemJson],Error>)->Void) )
}

public extension PicklistProtocol {
    var isPopulated: Bool {
        selectedItems.count > 0
    }
}
