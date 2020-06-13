
import Foundation
import WorkfinderCommon
import WorkfinderUI

class TextModel {

    var expandableLabelStates = [ExpandableLabelState]()
    
    init(associations: [HostAssociationJson]) {
        for association in associations {
            let host = association.host
            var state = ExpandableLabelState()
            state.text = host.description ?? ""
            state.isExpanded = false
            state.isExpandable = false
            expandableLabelStates.append(state)
        }
    }
}
