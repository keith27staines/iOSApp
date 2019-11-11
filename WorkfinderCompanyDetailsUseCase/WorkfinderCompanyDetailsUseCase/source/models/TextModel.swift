
import Foundation
import WorkfinderCommon

class TextModel {

    var expandableLabelStates = [ExpandableLabelState]()
    
    init(hosts: [F4SHost]) {
        for host in hosts {
            var state = ExpandableLabelState()
            state.text = host.summary ?? ""
            state.isExpanded = false
            state.isExpandable = false
            expandableLabelStates.append(state)
        }
    }
}
