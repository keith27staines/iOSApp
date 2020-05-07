
import UIKit
import WorkfinderCommon

class OtherPicklistItemEditorViewController: TextEditorViewController {
    var picklistItem: PicklistItemJson
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderTextView.text = "Other"
        textView.text = picklistItem.otherValue
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    init(coordinator: TextEditorCoordinatorProtocol,
         picklistItem: PicklistItemJson,
         type: PicklistType) {
        self.picklistItem = picklistItem
        super.init(coordinator: coordinator,
                   editorTitle: type.otherEditorTitle,
                   guidanceText: type.otherFieldGuidanceText,
                   placeholderText: type.otherFieldPlaceholderText)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
