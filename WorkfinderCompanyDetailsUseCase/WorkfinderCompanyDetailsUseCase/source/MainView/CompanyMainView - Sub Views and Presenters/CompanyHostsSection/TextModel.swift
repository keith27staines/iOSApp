
import Foundation
import WorkfinderCommon

class TextModel {

    var expandableLabelStates = [ExpandableLabelState]()
    
    init(hosts: [Host]) {
        for host in hosts {
            var state = ExpandableLabelState()
            state.text = host.description ?? ""
            state.isExpanded = false
            state.isExpandable = false
            expandableLabelStates.append(state)
        }
    }
}
