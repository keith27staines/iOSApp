
import UIKit
import WorkfinderUI

class SearchBarCell: UITableViewCell, Presentable, UISearchBarDelegate {
    static let identifier = "SearchBarCell"
    static let didStartEditingSearchFieldNotificationName = Notification.Name("didStartEditingSearchField")
    static let didEndEditingSearchFieldNotificationName = Notification.Name("didEndEditingSearchField")
    
    func presentWith(_ presenter: CellPresenter?) {
        guard let presenter = presenter as? SearchBarPresenter else { return }
        searchBar.placeholder = presenter.placeholderText
    }
    
    lazy var searchStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                searchBar,
                filtersView
            ]
        )
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        stack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        return stack
    }()
    
    lazy var filtersView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = WorkfinderColors.primaryColor.cgColor
        view.layer.cornerRadius = 24
        view.heightAnchor.constraint(equalToConstant: 360).isActive = true
        view.isHidden = true
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        let textfield: UITextField!
        if #available(iOS 13.0, *) {
            textfield = search.searchTextField
        } else {
            textfield = search.value(forKey: "searchField") as? UITextField
        }
        textfield.font = UIFont.systemFont(ofSize: 15)
        textfield.backgroundColor = UIColor.white
        textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkText])
        if let leftView = textfield.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = WorkfinderColors.primaryColor
        }
        if let rightView = textfield.rightView as? UIImageView {
            rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
            rightView.tintColor = WorkfinderColors.primaryColor
        }
        search.autocapitalizationType = .none
        search.autocorrectionType = .default
        search.tintColor = WorkfinderColors.primaryColor
        search.placeholder = "projects, companies, hosts"
        search.returnKeyType = .go
        search.searchBarStyle = .prominent
        search.layer.borderWidth = 2
        search.layer.cornerRadius = 24
        search.layer.borderColor = WorkfinderColors.primaryColor.cgColor
        search.layer.masksToBounds = true
        search.delegate = self
        return search
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _ = searchStack
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = true
        }
        filtersView.isHidden = false
        NotificationCenter.default.post(name: Self.didStartEditingSearchFieldNotificationName, object: self)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if #available(iOS 13.0, *) {
            searchBar.setShowsCancelButton(false, animated: true)
        } else {
            searchBar.showsCancelButton = false
        }
        filtersView.isHidden = true
        NotificationCenter.default.post(name: SearchBarCell.didEndEditingSearchFieldNotificationName, object: self)
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

