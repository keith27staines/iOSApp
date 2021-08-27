
import UIKit
import WorkfinderUI

class DiscoveryTrayView : UIView {
    
    let searchBarStack: UIView
    let searchDetail: SearchDetailView
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        return tableView
    }()
    
    func refresh() {}
    
    func configureViews() {
        isUserInteractionEnabled = true
        backgroundColor = UIColor.white
        layer.cornerRadius = 16
        layer.masksToBounds = false
        addSubview(searchBarStack)
        addSubview(tableView)
        addSubview(searchDetail)
        searchBarStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        tableView.anchor(top: searchBarStack.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        searchDetail.anchor(top: tableView.topAnchor, leading: tableView.leadingAnchor, bottom: tableView.bottomAnchor, trailing: tableView.trailingAnchor)
    }
    
    init(searchBarStack: UIStackView, searchDetail: SearchDetailView) {
        self.searchBarStack = searchBarStack
        self.searchDetail = searchDetail
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
