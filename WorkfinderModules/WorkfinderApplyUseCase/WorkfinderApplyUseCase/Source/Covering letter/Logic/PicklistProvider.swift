
import Foundation

public typealias PicklistsDictionary = [Picklist.PicklistType: Picklist]

public protocol PicklistProviderProtocol: class {
    var picklistType: Picklist.PicklistType { get }
    var moreToCome: Bool { get }
    func fetchMore(completion: @escaping ((Result<[PicklistItemJson],Error>) -> Void))
}



