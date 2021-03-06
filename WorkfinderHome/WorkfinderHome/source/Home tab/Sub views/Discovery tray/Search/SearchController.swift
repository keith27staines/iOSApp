
import WorkfinderCommon
import UIKit
import WorkfinderUI

class SearchController: NSObject {
    
    let filtersModel: FiltersModel
    let typeAheadDatasource: TypeAheadDataSource
    let searchResultsController: SearchResultsController
    var queryItems = [URLQueryItem]()
    weak var coordinator: HomeCoordinator?
    weak var log: F4SAnalyticsAndDebugging?
    enum SearchState {
        case hidden
        case showingTypeAhead
        case showingFilters
        case showingRoleResults
        case showingPeopleResults
    }
    var searchFieldShouldReturn: Bool { searchBar.text?.count ?? 0 > 0 }
    
    var state = SearchState.hidden {
        didSet {
            searchDetail.isHidden = false
            searchDetail.filtersView.isHidden = true
            searchDetail.searchResultsView.isHidden = true
            searchDetail.typeAheadView.isHidden = true
            switch state {
            case .hidden:
                filtersButton.isHidden = true
                searchDetail.isHidden = true
                filtersButton.alpha = 0
            case .showingTypeAhead:
                searchDetail.typeAheadView.isHidden = false
                filtersButton.alpha = 1
                filtersButton.isHidden = true
            case .showingFilters:
                filtersButton.alpha = 0
                filtersButton.isHidden = false
                searchDetail.filtersView.isHidden = false
            case .showingRoleResults:
                searchDetail.searchResultsView.isHidden = false
                filtersButton.alpha = 0
                filtersButton.isHidden = true
            case .showingPeopleResults:
                searchDetail.searchResultsView.isHidden = false
                filtersButton.alpha = 1
                filtersButton.isHidden = false
            }

            NotificationCenter.default.post(name: .wfHomeScreenSearchIsActive, object: self, userInfo: ["isSearchActive": !searchDetail.isHidden])
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                switch self.state {
                case .hidden:
                    break
                case .showingTypeAhead:
                    break
                case .showingFilters:
                    break
                case .showingRoleResults:
                    self.filtersButton.isHidden = false
                case .showingPeopleResults:
                    self.filtersButton.isHidden = true
                }
                self.filtersButton.alpha = self.filtersButton.isHidden ? 0 : 1
                self.searchBarStack.layoutIfNeeded()
            } completion: { (complete) in
                switch self.state {
                case .hidden:
                    break
                case .showingTypeAhead:
                    self.searchDetail.typeAheadView.isHidden = false
                case .showingFilters:
                    self.filtersButton.isHidden = false
                    self.searchDetail.filtersView.isHidden = false
                case .showingRoleResults:
                    self.searchDetail.searchResultsView.isHidden = false
                    self.filtersButton.isHidden = false
                case .showingPeopleResults:
                    self.searchDetail.searchResultsView.isHidden = false
                    self.filtersButton.isHidden = true
                }
            }
        }
    }
    
    lazy var searchBar: KSSearchBar = {
        let searchBar = KSSearchBar()
        searchBar.tintColor = WorkfinderColors.primaryColor
        searchBar.delegate = self
        searchBar.placeholder = "Projects or people"
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
        case .showingRoleResults: state = .showingFilters
        default: break
        }
    }
    
    func applyFilters() {
        queryItems = filtersModel.queryItems
        log?.track(.search_home_apply_filters(search: queryItems.queryString))
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
    
    lazy var beginTypingLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.numberOfLines = 0
        label.text = "Begin typing to see some suggestions"
        label.textColor = UIColor.lightGray
        label.isHidden = true
        return label
    }()
    
    lazy var searchDetail: SearchDetailView = {
        let view = SearchDetailView(
            filtersModel: filtersModel,
            typeAheadDataSource: typeAheadDatasource,
            didSelectTypeAheadItem: { [weak self] item in
                self?.searchBar.resignFirstResponder()
                self?.coordinator?.dispatchTypeAheadItem(item)
            },
            didTapApplyFilters: { [weak self] filtersModel in
                self?.applyFilters()
            }
        )
        view.searchResultsView.controller = searchResultsController
        view.addSubview(beginTypingLabel)
        beginTypingLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        return view
    }()
    
    init(
        coordinator: HomeCoordinator?,
        log: F4SAnalyticsAndDebugging?,
        typeAheadService: TypeAheadServiceProtocol,
        filtersModel: FiltersModel,
        searchResultsController: SearchResultsController
    ) {
        self.coordinator = coordinator
        self.log = log
        typeAheadDatasource = TypeAheadDataSource(typeAheadService: typeAheadService)
        self.filtersModel = filtersModel
        self.searchResultsController = searchResultsController
        super.init()
        state = .hidden
        addNotificationListeners()
    }
    
    
    func addNotificationListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(popularOnWorkfinderTapListener), name: .wfHomeScreenPopularOnWorkfinderTapped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rolesTabWasSelected), name: .wfSearchResultsRoleTabSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(peopleTabWasSelected), name: .wfSearchResultsPeopleTabSelected, object: nil)
    }
    @objc func rolesTabWasSelected() {
        guard searchBar.window != nil else { return }
        state = .showingRoleResults
    }
    @objc func peopleTabWasSelected() {
        guard searchBar.window != nil else { return }
        state = .showingPeopleResults
    }
    
    @objc func popularOnWorkfinderTapListener(notification: Notification) {
        guard let searchString = (notification.object as? CapsuleData)?.searchText
        else { return }
        log?.track(.search_home_perform_popular(search: searchString))
        searchBar.text = searchString
        searchBar.animateInCancelButton()
        performSearch()
    }
}

extension SearchController: KSSearchBarDelegate {
    func searchBarButtonTapped(_ searchbar: KSSearchBar) {
        log?.track(.search_home_perform_full(search: searchbar.text ?? ""))
        searchBar.resignFirstResponder()
        performSearch()
    }
    
    func searchbarTextDidChange(_ searchbar: KSSearchBar) {
        performTypeAhead(string: searchBar.text)
        searchTextDidUpdate()
    }
    
    func searchbarDidBeginEditing(_ searchbar: KSSearchBar) {
        log?.track(.search_home_typeahead_start)
        setStateFromSearchText()
        DispatchQueue.main.async {
            self.configureKeyboardReturnKey()
        }
    }
    
    func searchBarDidCancel(_ searchbar: KSSearchBar) {
        log?.track(.search_home_cancel_typeahead)
        state = .hidden
    }
    
    func searchTextDidUpdate() {
        setStateFromSearchText()
        configureKeyboardReturnKey()
    }
    
    func searchBarShouldReturn(_ searchbar: KSSearchBar) -> Bool {
        let shouldReturn = searchFieldShouldReturn
        if shouldReturn {
            searchBar.resignFirstResponder()
            performSearch()
        }
        return shouldReturn
    }
}


extension SearchController {
    
    func setStateFromSearchText() {
        state = .showingTypeAhead
        beginTypingLabel.isHidden = false
        if !searchBar.isFirstResponder {
            beginTypingLabel.isHidden = true
            return
        }
        beginTypingLabel.isHidden = searchFieldShouldReturn
    }
    
    func configureKeyboardReturnKey() {
        guard let keyboard = getKeyboard() else { return }
        keyboard.setValue(searchFieldShouldReturn, forKey: "returnKeyEnabled")
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
}

extension SearchController {
    
    func performSearch() {
        setStateFromSearchText()
        let searchText = searchBar.text
        var queryItems = [URLQueryItem(name: "q", value: searchText)]
        queryItems.append(contentsOf: self.queryItems)
        searchResultsController.queryItems = queryItems
        switch typeAheadDatasource.result {
        case .success(let typeAheadJson):
            searchResultsController.typeAheadJson = typeAheadJson
        case .failure(_), .none:
            searchResultsController.typeAheadJson = nil
        }
        searchResultsController.selectTab(index: 0)
    }
    
    func performTypeAhead(string: String?) {
        guard let string = string, string.count > 0 else {
            typeAheadDatasource.clear()
            return
        }
        typeAheadDatasource.searchString = string
    }
}

extension Array where Element == URLQueryItem {
    var queryString: String {
        var components = URLComponents()
        components.queryItems = self
        return components.query ?? ""
    }
}
