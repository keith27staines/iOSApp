import WorkfinderCommon
import WorkfinderServices

public class HardCodedPicklist: Picklist {
    override public func fetchItems(completion: @escaping ((PicklistProtocol, Result<[PicklistItemJson], Error>) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            completion(self, Result<[PicklistItemJson], Error>.success(self.items))
        }
    }
}
