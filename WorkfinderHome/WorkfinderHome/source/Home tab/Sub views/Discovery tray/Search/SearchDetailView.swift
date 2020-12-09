
import UIKit

class SearchDetailView: UIView {
    
    let filtersModel: FiltersModel
    
    lazy var filtersView: FiltersView = {
        FiltersView(filtersModel: filtersModel, didTapApplyFilters: didTapApplyFilters)
    }()
    
    let typeAheadView: TypeAheadView
    
    lazy var searchResultsView: SearchResultsView = {
        SearchResultsView()
    }()
    
    var didTapApplyFilters: (FiltersModel) -> Void
    
    init(
        filtersModel: FiltersModel,
        typeAheadDataSource: TypeAheadDataSource,
        didSelectTypeAheadText: @escaping (String) -> Void,
        didTapApplyFilters: @escaping (FiltersModel) -> Void
    ) {
        self.filtersModel = filtersModel
        self.didTapApplyFilters = didTapApplyFilters
        self.typeAheadView = TypeAheadView(filtersModel: filtersModel, typeAheadDataSource: typeAheadDataSource)
        super.init(frame: CGRect.zero)
        configureViews()
        typeAheadView.didSelectText = didSelectTypeAheadText
    }
    
    func configureViews() {
        backgroundColor = UIColor.white
        let subviews = [filtersView, typeAheadView, searchResultsView]
        subviews.forEach { (subview) in
            addSubview(subview)
            subview.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
