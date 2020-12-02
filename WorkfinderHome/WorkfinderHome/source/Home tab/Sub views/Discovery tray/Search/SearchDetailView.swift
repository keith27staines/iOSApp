
import UIKit

class SearchDetailView: UIView {
    lazy var categoriesView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.red
        return tableView
    }()
    
    lazy var typeAheadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.green
        return view
    }()
    
    lazy var searchResultsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    func configureViews() {
        let subviews = [categoriesView, typeAheadView, searchResultsView]
        subviews.forEach { (subview) in
            addSubview(subview)
            subview.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)        }
        addSubview(categoriesView)
        addSubview(typeAheadView)
        addSubview(searchResultsView)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
