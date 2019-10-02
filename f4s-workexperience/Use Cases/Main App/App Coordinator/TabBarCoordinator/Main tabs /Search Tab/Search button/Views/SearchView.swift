//
//  SearchView.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 13/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol SearchViewDelegate : class {
    func searchView(_ view: SearchViewProtocol, didChangeState state: SearchViewStateMachine.State)
    func searchView(_ view: SearchViewProtocol, didChangeText text: String)
    func searchView(_ view: SearchViewProtocol, didSelectItem indexPath: IndexPath)
}

private let spacing : CGFloat = 10
private let iconSize: CGSize = CGSize(width: 44, height: 44)
private let collapsedSize = CGSize(width: 2 * spacing + iconSize.width, height: 2 * spacing + iconSize.height)

class SearchView: UIView {
    let screenName = ScreenName.companySearch
    private var expandedWidth: CGFloat = 8 * spacing + 4 * iconSize.width
    private var horizontallyExpandedSize: CGSize { return CGSize(width: expandedWidth, height: 2 * spacing + iconSize.height) }
    private var searchResultsRevealedSize: CGSize { return CGSize(width: expandedWidth, height: 1000) }
    
    weak var delegate: SearchViewDelegate?
    var dataSource: UITableViewDataSource? {
        didSet {
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }
    
    func refreshFromDatasource() {
        tableView.reloadData()
        finishActivity()
    }
    
    lazy private var stateMachine = SearchViewStateMachine(searchView: self)
    var log: F4SAnalyticsAndDebugging!
    
    var state: SearchViewStateMachine.State { return stateMachine.value }
    
    private let rotation: CGFloat = CGFloat(0.5 * Double.pi)
    
    func animateExpandHorizontally() {
        tableView.removeFromSuperview()
        searchBar.removeFromSuperview()
        heightConstraint?.constant = horizontallyExpandedSize.height
        widthConstraint?.constant = horizontallyExpandedSize.width
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.superview?.layoutIfNeeded()
                self.searchIcon.transform = CGAffineTransform(rotationAngle: self.rotation)
                
        }, completion: { (finished) in
            UIView.animate(withDuration: 0.3, animations: {
                self.horizontalStack.alpha = 1.0
                self.horizontalStack.isUserInteractionEnabled = true
                self.layoutIfNeeded()
            })
        })
    }
    
    func minimizeSearchUI() {
        stateMachine.minimizeSearchUI()
    }
    
    func animateCollapseHorizontally() {
        horizontalStack.isUserInteractionEnabled = false
        searchBar.isUserInteractionEnabled = false
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [],
            animations: { [weak self] in
                guard let this = self else { return }
                this.horizontalStack.alpha = 0.0
                this.searchBar.alpha = 0.0
                this.searchIcon.transform = CGAffineTransform.identity
                
        }, completion: { [weak self] (finished) in
            guard let this = self else { return }
            this.tableView.removeFromSuperview()
            this.searchBar.removeFromSuperview()
            this.heightConstraint?.constant = collapsedSize.height
            this.widthConstraint?.constant = collapsedSize.width
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    self?.superview?.layoutIfNeeded()
            })
        })
    }
    
    func animateRevealSearchResults() {
        heightConstraint?.constant = searchResultsRevealedSize.height
        widthConstraint?.constant = horizontallyExpandedSize.width
        addSearchBar()
        addTableView()
        searchBar.alpha = 0.0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.superview?.layoutIfNeeded()
                
        }, completion: { [weak self] (finished) in
            guard let this = self else { return }
            this.horizontalStack.isUserInteractionEnabled = true
            this.tableView.reloadData()
            if this.dataSource?.tableView(this.tableView, numberOfRowsInSection: 0) == 0 {
                this.searchBar.becomeFirstResponder()
            }
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                guard let this = self else { return }
                this.searchBar.alpha = 1.0
                this.tableView.alpha  = 1.0
            })
        })
    }

    lazy var searchIcon: UIImageView = {
        let image = UIImage(named: "search")!.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.blue
        imageView.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleSearchTapped))
        imageView.heightAnchor.constraint(equalToConstant: iconSize.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true
        imageView.addGestureRecognizer(recognizer)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    @objc func handleSearchTapped(_ sender: Any?) {
        endEditing(false)
        stateMachine.searchTapped()
    }
    
    @objc func handlePersonTapped(_ sender: Any?) {
        endEditing(false)
        stateMachine.personTapped()
    }
    
    @objc func handleCompanyTapped(_ sender: Any?) {
        endEditing(false)
        stateMachine.companyTapped()
    }
    
    @objc func handleLocationTapped(_ sender: Any?) {
        endEditing(false)
        stateMachine.locationTapped()
    }
    
    lazy var horizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            personSelectorView,
            companySelectorView,
            mapSelectorView
            ])
        personSelectorView.isHidden = true
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 2*spacing
        return stack
    }()
    
    lazy var personSelectorView: UIView = { SearchModeSelectorView(imageName: "generic_person", text: "Person", tapped: handlePersonTapped)}()
    
    lazy var companySelectorView: UIView = { SearchModeSelectorView(imageName: "generic_company", text: "Company", tapped: handleCompanyTapped) }()
    
    lazy var mapSelectorView: UIView = { SearchModeSelectorView(imageName: "map", text: "Location", tapped: handleLocationTapped) }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = SearchViewFooterView(tapped: { [weak self] in
            self?.searchBar.endEditing(true)
        })
        tableView.clipsToBounds = true
        return tableView
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.alpha = 1
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    init(expandedWidth: CGFloat, frame: CGRect) {
        self.expandedWidth = expandedWidth
        super.init(frame: frame)
    }
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = collapsedSize.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        tintColor = UIColor.red
        guard heightConstraint == nil else { return }
        addSubview(searchIcon)
        addSubview(horizontalStack)

        backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize.zero
        layer.cornerRadius = 8
        backgroundColor = UIColor.white
        searchIcon.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: spacing, left: spacing, bottom: 0, right: 0))
        horizontalStack.anchor(top: searchIcon.topAnchor, leading: searchIcon.trailingAnchor, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 2 * spacing + iconSize.width, bottom: 0, right: spacing))
        horizontalStack.alpha = 0.0
        searchBar.alpha = 0.0
        heightConstraint = heightAnchor.constraint(equalToConstant: collapsedSize.height)
        widthConstraint = widthAnchor.constraint(equalToConstant: collapsedSize.width)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
        widthConstraint?.isActive = true
        log.screen(screenName)
    }
    
    func addSearchBar() {
        guard searchBar.superview == nil else { return }
        addSubview(searchBar)
        searchBar.anchor(top: horizontalStack.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing:
            trailingAnchor, padding: UIEdgeInsets(top: spacing, left: 0, bottom: 0, right: 0))
        searchBar.isUserInteractionEnabled = true
    }
    
    func addTableView() {
        tableView.alpha = 0
        guard tableView.superview == nil else { return }
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, leading: searchBar.leadingAnchor, bottom: bottomAnchor, trailing: searchBar.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: collapsedSize.height/2, right: 0))
         addSubview(activityIndicator)
         activityIndicator.anchor(top: tableView.topAnchor, leading: nil, bottom: nil, trailing: nil)
         activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    private var activityCount = 0
    func startActivity() {
        activityCount += 1
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func finishActivity() {
        activityCount -= 1
        if activityCount < 0 { activityCount = 0 }
        if activityCount == 0 {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
}

extension SearchView : SearchViewProtocol {}

extension SearchView : UISearchBarDelegate {
    
    @objc func processTextChange() {
        startActivity()
        let searchText = searchBar.text ?? ""
        stateMachine.searchTextChanged(searchText)
        delegate?.searchView(self, didChangeText: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        finishActivity()
        NSObject.cancelPreviousPerformRequests(
            withTarget: self,
            selector: #selector(processTextChange),
            object: searchBar)
        self.perform(
            #selector(processTextChange),
            with: searchBar,
            afterDelay: 0.2)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension SearchView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        delegate?.searchView(self, didSelectItem: indexPath)
    }
}
