
import UIKit

class SearchDetailView: UIView {
    lazy var categoriesView: FiltersView = {
        FiltersView()
    }()
    
    lazy var typeAheadView: TypeAheadView = {
        TypeAheadView()
    }()
    
    lazy var searchResultsView: SearchResultsView = {
        SearchResultsView()
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    func configureViews() {
        backgroundColor = UIColor.white
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
