
import UIKit
import WorkfinderCommon

class FreeTextEditorViewController: TextEditorViewController {

    let freeTextPicker: TextblockPicklist
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeholderTextView.text = freeTextPicker.type.textblockPlaceholder
        if freeTextPicker.selectedItems.count > 0 {
            textView.text = freeTextPicker.selectedItems[0].value ?? ""
        }
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        freeTextPicker.deselectAll()
        freeTextPicker.selectItem(PicklistItemJson(uuid: "text", value: text))
        super.viewWillDisappear(animated)
    }
    
    init(coordinator: TextEditorCoordinatorProtocol,
         freeTextPicker: TextblockPicklist) {
        self.freeTextPicker = freeTextPicker
        super.init(coordinator: coordinator,
                   editorTitle: freeTextPicker.type.textBlockEditorTitle,
                   guidanceText: freeTextPicker.type.textblockGuidance,
                   placeholderText: freeTextPicker.type.textblockPlaceholder)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
