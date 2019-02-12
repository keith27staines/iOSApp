//
//  SearchViewStateMachine.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 09/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

class SearchViewStateMachine {
    
    let activeColor = UIColor.red
    let inactiveColor = UIColor(white: 0.3, alpha: 1)
    let disabledColor = UIColor(white: 0.9, alpha: 1)
    
    private (set) var searchBarPlaceholder = ""
    private (set) var searchBarReturnKeyType = UIReturnKeyType.default
    private (set) var searchBarTextContentType = UITextContentType.postalCode
    private (set) var searchBarAutocapitalizationType = UITextAutocapitalizationType.none
    private (set) var personIconTintColor: UIColor {
        set {}
        get { return disabledColor }
    }
    private (set) var companyIconTintColor = UIColor.lightGray
    private (set) var mapIconTintColor = UIColor.lightGray
    
    private var animateExpandHorizontally: (() -> Void)?
    private var animateCollapseHorizontally: (() -> Void)?
    private var animateRevealSearchResults: (() -> Void)?
    
    weak private var searchView: SearchViewProtocol!
    
    enum State {
        case collapsed
        case horizontallyExpanded
        case searchingLocation
        case searchingPeople
        case searchingCompany
    }
    
    init(searchView: SearchViewProtocol) {
        self.searchView = searchView
        self.animateExpandHorizontally = searchView.animateExpandHorizontally
        self.animateCollapseHorizontally = searchView.animateCollapseHorizontally
        self.animateRevealSearchResults = searchView.animateRevealSearchResults
        value = .collapsed
    }
    
    func minimizeSearchUI() { value = .collapsed }
    
    private func updateViewAndInformViewDelegate() {
        guard let view = searchView else { return }
        view.searchBar.placeholder = searchBarPlaceholder
        view.searchBar.autocapitalizationType = searchBarAutocapitalizationType
        view.searchBar.returnKeyType = searchBarReturnKeyType
        view.searchBar.textContentType = searchBarTextContentType
        view.personIcon.tintColor = personIconTintColor
        view.mapIcon.tintColor = mapIconTintColor
        view.companyIcon.tintColor = companyIconTintColor
        view.delegate?.searchView(view, didChangeState: value)
    }
    
    /// view cannot change state explicitly, all state changes occur in response to triggers
    private (set) var value: State {
        didSet {
            personIconTintColor = inactiveColor
            mapIconTintColor = inactiveColor
            companyIconTintColor = inactiveColor
            switch value {
            case .collapsed: animateCollapseHorizontally?()
            case .horizontallyExpanded: animateExpandHorizontally?()
            case .searchingLocation:
                searchBarPlaceholder = "Postcode"
                searchBarReturnKeyType = .go
                searchBarAutocapitalizationType = .allCharacters
                searchBarTextContentType = UITextContentType.postalCode
                mapIconTintColor = activeColor
                if oldValue != .searchingLocation { changedSearchType() }
            case .searchingPeople:
                searchBarPlaceholder = "Person's name"
                searchBarReturnKeyType = .done
                searchBarAutocapitalizationType = .words
                searchBarTextContentType = UITextContentType.name
                personIconTintColor = activeColor
                if oldValue != .searchingPeople { changedSearchType() }
            case .searchingCompany:
                searchBarPlaceholder = "Company name"
                searchBarReturnKeyType = .done
                searchBarAutocapitalizationType = .words
                searchBarTextContentType = UITextContentType.organizationName
                companyIconTintColor = activeColor
                if oldValue != .searchingCompany { changedSearchType() }
            }
            updateViewAndInformViewDelegate()
        }
    }
    
    func changedSearchType() {
        searchView.searchBar.text = ""
        animateRevealSearchResults?()
    }
}

// MARK:- State change triggers
extension SearchViewStateMachine {
    func searchTapped() {
        switch value {
        case .collapsed:
            value = .horizontallyExpanded
        default:
            value = .collapsed
        }
    }
    
    func personTapped() {
        switch value {
        case .searchingPeople:
            value = .horizontallyExpanded
        default:
            value = .searchingPeople
        }
    }
    
    func companyTapped() {
        switch value {
        case .searchingCompany:
            value = .horizontallyExpanded
        default:
            value = .searchingCompany
        }
    }
    
    func locationTapped() {
        switch value {
        case .searchingLocation:
            value = .horizontallyExpanded
        default:
            value = .searchingLocation
        }
    }

}

