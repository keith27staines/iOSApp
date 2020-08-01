
import UIKit
import WorkfinderCommon

class FreeTextEditorViewController: TextEditorViewController {

    let freeTextPicker: TextblockPicklist
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit \(freeTextPicker.type.title.capitalized)"
        placeholderTextView.text = freeTextPicker.type.textblockPlaceholder
        if freeTextPicker.selectedItems.count > 0 {
            textView.text = freeTextPicker.selectedItems[0].value ?? ""
        } else {
            textView.text = freeTextPicker.previousSelectedItemsBeforeDeselectAll[0].value ?? ""
        }
        placeholderTextView.isHidden = !textView.text.isEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        freeTextPicker.deselectAll()
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            freeTextPicker.selectItem(PicklistItemJson(uuid: PicklistItemJson.freeTextUuid, value: text))
        }
        super.viewWillDisappear(animated)
    }
    
    init(coordinator: TextEditorCoordinatorProtocol,
         freeTextPicker: TextblockPicklist) {
        self.freeTextPicker = freeTextPicker
        super.init(coordinator: coordinator,
                   editorTitle: freeTextPicker.type.textBlockEditorTitle,
                   guidanceText: freeTextPicker.type.textblockGuidance,
                   placeholderText: freeTextPicker.type.textblockPlaceholder,
                   maxWordCount: 300)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
