
import UIKit
import WorkfinderUI

class SearchController: NSObject {
    
    let filtersModel: FiltersModel = FiltersModel()
    let typeAheadDatasource: TypeAheadDataSource
    
    enum SearchState {
        case hidden
        case showingTypeAhead
        case showingFilters
        case showingResults
    }
    
    var state = SearchState.hidden {
        didSet {
            searchDetail.isHidden = false
            searchDetail.filtersView.isHidden = true
            searchDetail.searchResultsView.isHidden = true
            searchDetail.typeAheadView.isHidden = true
            switch state {
            case .hidden: searchDetail.isHidden = true
            case .showingTypeAhead: searchDetail.typeAheadView.isHidden = false
            case .showingFilters: searchDetail.filtersView.isHidden = false
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
        SearchDetailView(
            filtersModel: filtersModel,
            typeAheadDataSource: typeAheadDatasource,
            didSelectTypeAheadText: { string in
                self.searchBar.text = string
                self.searchTextDidUpdate()
            }
        )
    }()
    
    init(typeAheadService: TypeAheadServiceProtocol) {
        typeAheadDatasource = TypeAheadDataSource(typeAheadService: typeAheadService)
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
        setStateFromSearchText()
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
        performTypeAhead(string: searchBar.text)
        searchTextDidUpdate()
    }
    
    func searchTextDidUpdate() {
        setStateFromSearchText()
        configureKeyboardReturnKey()
    }
    
    func setStateFromSearchText() {
        if searchBar.text == nil || searchBar.text?.isEmpty == true {
            state = .showingFilters
        } else {
            state = .showingTypeAhead
        }
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
        searchBar.text?.count ?? 0 > 2 ? true : false
    }
}

extension SearchController {
    func performTypeAhead(string: String?) {
        guard let string = string, string.count > 2 else { return }
        typeAheadDatasource.string = makeFullQueryString(search: string, filters: filtersModel.queryString)
    }
    
    func makeFullQueryString(search: String?, filters: String?) -> String? {
        var queryString = "?"
        if let search = search { queryString.append("q=\(search)") }
        if let filters = filters {
            if search != nil { queryString.append("&")}
            queryString.append(filters)
        }
        
        let allowedCharacters = CharacterSet(["-","_",".","=","&","?"])
        
        return queryString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics.union(allowedCharacters))
    }

}
