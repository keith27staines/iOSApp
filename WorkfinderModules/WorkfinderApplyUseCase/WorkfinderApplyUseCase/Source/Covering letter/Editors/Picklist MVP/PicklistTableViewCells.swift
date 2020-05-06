
import UIKit
import WorkfinderCommon

class StandardPicklistItemTableViewCell: UITableViewCell {
    func configureWith(_ item: PicklistItemJson, picklist: PicklistProtocol) {
        textLabel?.text = item.guarenteedName
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.guaranteedUuid == item.guaranteedUuid
        }) {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
}

class OtherPicklistItemTableViewCell: UITableViewCell {
    func configureWith(_ item: PicklistItemJson, picklist: PicklistProtocol) {
        textLabel?.text = item.value ?? item.name
        if picklist.selectedItems.contains(where: { (otherItem) -> Bool in
            otherItem.guaranteedUuid == item.guaranteedUuid
        }) {
            accessoryType = .checkmark
        } else {
            accessoryType = .disclosureIndicator
        }
    }
}
