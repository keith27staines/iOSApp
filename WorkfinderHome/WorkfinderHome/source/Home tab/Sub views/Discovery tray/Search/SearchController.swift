
import UIKit
import WorkfinderUI

class SearchController: NSObject {
    
    let filtersModel: FiltersModel
    let typeAheadDatasource: TypeAheadDataSource
    var filtersString: String?
    
    enum SearchState {
        case hidden
        case showingTypeAhead
        case showingFilters
        case showingResults
    }
    
    var state = SearchState.hidden {
        didSet {
            filtersButton.isHidden = true
            searchDetail.isHidden = false
            searchDetail.filtersView.isHidden = true
            searchDetail.searchResultsView.isHidden = true
            searchDetail.typeAheadView.isHidden = true
            switch state {
            case .hidden:
                searchDetail.isHidden = true
            case .showingTypeAhead:
                searchDetail.typeAheadView.isHidden = false
                filtersButton.alpha = 1
                filtersButton.isHidden = true
            case .showingFilters:
                filtersButton.alpha = 0
                filtersButton.isHidden = false
                searchDetail.filtersView.isHidden = false
            case .showingResults:
                searchDetail.searchResultsView.isHidden = false
                filtersButton.alpha = 0
                filtersButton.isHidden = false
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.searchBarStack.layoutIfNeeded()
                self.filtersButton.alpha = self.filtersButton.isHidden ? 0 : 1
            } completion: { (complete) in
                switch self.state {
                case .hidden:
                    break
                case .showingTypeAhead:
                    self.searchDetail.typeAheadView.isHidden = false
                case .showingFilters:
                    self.filtersButton.isHidden = false
                    self.searchDetail.filtersView.isHidden = false
                case .showingResults:
                    self.searchDetail.searchResultsView.isHidden = false
                    self.filtersButton.isHidden = false
                }
            }
        }
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = SearchBar()
        searchBar.delegate = self
        searchBar.textEntryField?.delegate = self
        return searchBar
    }()
    
    lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.tintColor = WorkfinderColors.primaryColor
        let image = UIImage(named: "dt_filter")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(toggleFilters), for: .touchUpInside)
        return button
    }()
    
    @objc func toggleFilters() {
        switch state {
        case .showingFilters:
            applyFilters()
        case .showingResults: state = .showingFilters
        default: break
        }
    }
    
    func applyFilters() {
        filtersString = filtersModel.queryString
        self.performSearch()
    }
    
    lazy var searchBarStack:UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(searchBar)
        stack.addArrangedSubview(filtersButton)
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var searchDetail: SearchDetailView = {
        SearchDetailView(
            filtersModel: filtersModel,
            typeAheadDataSource: typeAheadDatasource,
            didSelectTypeAheadText: { string in
                self.searchBar.text = string
                self.searchTextDidUpdate()
            },
            didTapApplyFilters: { [weak self] filtersModel in
                self?.applyFilters()
            }
        )
    }()
    
    init(typeAheadService: TypeAheadServiceProtocol, filtersModel: FiltersModel) {
        typeAheadDatasource = TypeAheadDataSource(typeAheadService: typeAheadService)
        self.filtersModel = filtersModel
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
        state = .showingTypeAhead
    }
    
    func configureKeyboardReturnKey() {
        guard let keyboard = getKeyboard() else { return }
        keyboard.setValue(shouldEnableReturnKey, forKey: "returnKeyEnabled")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
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
        searchBar.text?.count ?? 0 > 0 ? true : false
    }
}

extension SearchController {
    
    func performSearch() {
        guard let queryString = makeFullQueryString(
                search: searchBar.text,
                filters: filtersString) else {
            return
        }
        searchDetail.searchResultsView.queryString = queryString
        state = .showingResults
    }
    
    func performTypeAhead(string: String?) {
        typeAheadDatasource.string = string
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
