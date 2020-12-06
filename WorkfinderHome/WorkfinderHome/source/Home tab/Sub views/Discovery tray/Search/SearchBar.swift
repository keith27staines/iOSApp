
import UIKit
import WorkfinderUI

class SearchBar: UISearchBar {
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var textEntryField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "searchField") as? UITextField
        }
    }
    
    func configureViews() {
        if let leftView = textEntryField?.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = WorkfinderColors.primaryColor
        }
        autocapitalizationType = .none
        autocorrectionType = .default
        placeholder = "projects, companies, hosts"
        returnKeyType = .search
        showsCancelButton = true
        enablesReturnKeyAutomatically = false
        tintColor = WorkfinderColors.primaryColor
    }
}
