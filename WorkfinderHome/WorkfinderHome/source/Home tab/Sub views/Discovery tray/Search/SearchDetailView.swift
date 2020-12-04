
import UIKit

class SearchDetailView: UIView {
    
    let filtersModel: FiltersModel
    
    lazy var filtersView: FiltersView = {
        FiltersView(filtersModel: filtersModel)
    }()
    
    lazy var typeAheadView: TypeAheadView = {
        TypeAheadView()
    }()
    
    lazy var searchResultsView: SearchResultsView = {
        SearchResultsView()
    }()
    
    init(filtersModel: FiltersModel) {
        self.filtersModel = filtersModel
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    func configureViews() {
        backgroundColor = UIColor.white
        let subviews = [filtersView, typeAheadView, searchResultsView]
        subviews.forEach { (subview) in
            addSubview(subview)
            subview.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)        }
        addSubview(filtersView)
        addSubview(typeAheadView)
        addSubview(searchResultsView)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
