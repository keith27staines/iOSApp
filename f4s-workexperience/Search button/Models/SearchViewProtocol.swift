//
//  SearchViewProtocol.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 09/02/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit

protocol SearchViewProtocol : class {
    var searchBar: UISearchBar { get }
    var personSelectorView: UIView { get }
    var mapSelectorView: UIView { get }
    var companySelectorView: UIView { get }
    var delegate: SearchViewDelegate? { get }
    var state: SearchViewStateMachine.State { get }
    func animateExpandHorizontally() -> Void
    func animateCollapseHorizontally() -> Void
    func animateRevealSearchResults() -> Void
}
