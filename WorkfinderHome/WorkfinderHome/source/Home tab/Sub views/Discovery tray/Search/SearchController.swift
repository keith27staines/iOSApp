
import UIKit
import WorkfinderUI

class SearchController: NSObject {
    
    enum SearchState {
        case hidden
        case showingTypeAhead
        case showingFilters
        case showingResults
    }
    
    var state = SearchState.hidden {
        didSet {
            searchDetail.isHidden = false
            searchDetail.categoriesView.isHidden = true
            searchDetail.searchResultsView.isHidden = true
            searchDetail.typeAheadView.isHidden = true
            switch state {
            case .hidden: searchDetail.isHidden = true
            case .showingTypeAhead: searchDetail.typeAheadView.isHidden = false
            case .showingFilters: searchDetail.categoriesView.isHidden = false
            case .showingResults: searchDetail.searchResultsView.isHidden = false
            }
        }
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = SearchBar()
        searchBar.delegate = self
        searchBar.textEntryField?.delegate = self
        return searchBar
    }()
    
    lazy var searchDetail: SearchDetailView = {
        SearchDetailView()
    }()
    
    override init() {
        super.init()
        state = .hidden
    }

}

extension SearchController: UISearchBarDelegate, UITextFieldDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = true
        }
        state = .showingTypeAhead
        performTypeAhead(string: searchBar.text)
        DispatchQueue.main.async {
            self.configureKeyboardReturnKey()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            searchBar.showsCancelButton = false
        }

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.isEmpty == true {
            state = .showingFilters
        } else {
            state = .showingFilters
        }
        configureKeyboardReturnKey()
    }
    
    func configureKeyboardReturnKey() {
        guard let keyboard = getKeyboard() else { return }
        keyboard.setValue(shouldEnableReturnKey, forKey: "returnKeyEnabled")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        state = .showingResults
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        state = .hidden
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        shouldEnableReturnKey
    }
    
    func getKeyboard() -> UIView?
    {
        for window in UIApplication.shared.windows.reversed()
        {
            if window.debugDescription.contains("UIRemoteKeyboardWindow") {
                if let inputView = window.subviews
                    .first? // UIInputSetContainerView
                    .subviews
                    .first // UIInputSetHostView
                {
                    for view in inputView.subviews {
                        if view.debugDescription.contains("_UIKBCompatInputView"), let keyboard = view.subviews.first, keyboard.debugDescription.contains( "UIKeyboardAutomatic") {
                            return keyboard
                        }
                    }
                }
                
            }
        }
        return nil
    }
    
    var shouldEnableReturnKey: Bool {
        searchBar.text?.count ?? 0 > 3 ? true : false
    }
}

extension SearchController {
    func performTypeAhead(string: String?) {
        guard let string = string, string.count > 3 else { return }
        // Get type ahead results
    }
}
