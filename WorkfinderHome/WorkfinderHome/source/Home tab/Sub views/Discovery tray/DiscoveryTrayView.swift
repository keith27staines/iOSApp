
import UIKit
import WorkfinderUI

class DiscoveryTrayView : UIView {
    static let didStartEditingSearchFieldNotificationName = Notification.Name("didStartEditingSearchField")
    static let didEndEditingSearchFieldNotificationName = Notification.Name("didEndEditingSearchField")
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        let textfield: UITextField!
        if #available(iOS 13.0, *) {
            textfield = search.searchTextField
        } else {
            textfield = search.value(forKey: "searchField") as? UITextField
        }
        if let leftView = textfield.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = WorkfinderColors.primaryColor
        }
        search.autocapitalizationType = .none
        search.autocorrectionType = .default
        search.placeholder = "projects, companies, hosts"
        search.returnKeyType = .go
        search.showsCancelButton = true
        search.tintColor = WorkfinderColors.primaryColor
        search.delegate = self
        addSubview(search)
        search.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        return search
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        addSubview(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        return tableView
    }()
    
    func refresh() {}
    
    func configureViews() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor.white
        layer.cornerRadius = 16
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
    }
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


extension DiscoveryTrayView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = true
        }
        NotificationCenter.default.post(name: Self.didStartEditingSearchFieldNotificationName, object: self)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            searchBar.showsCancelButton = false
        }
        NotificationCenter.default.post(name: Self.didEndEditingSearchFieldNotificationName, object: self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // do search
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        true
    }

}
