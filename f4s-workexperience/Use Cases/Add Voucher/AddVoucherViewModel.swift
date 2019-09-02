import Foundation
import WorkfinderCommon

public enum Workflow {
    case apply
    case accept
}

public class AddVoucherViewModel {
    
    let workflow: Workflow
    
    public init(workflow: Workflow) {
        self.workflow = workflow
    }
}
