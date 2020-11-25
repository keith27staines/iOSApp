import UIKit
import WorkfinderUI

class HorizontallyScrollingCell: UITableViewCell {
    private var verticalMargin = CGFloat(20)
    private var scrollViewHeight = CGFloat(45)
    
    func updateHeightConstraint(verticalMargin: CGFloat = 20, scrollViewHeight: CGFloat = 45) {
        self.verticalMargin = verticalMargin
        self.scrollViewHeight = scrollViewHeight
        heightConstraint.constant = verticalMargin + scrollViewHeight + verticalMargin
        scrollViewHeightConstraint.constant = scrollViewHeight
    }

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = contentView.heightAnchor.constraint(equalToConstant: verticalMargin + scrollViewHeight + verticalMargin)
        return constraint
    }()
    
    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
        return constraint
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        heightConstraint.isActive = true
        scrollViewHeightConstraint.isActive = true
        contentView.addSubview(scrollView)
        scrollView.anchor(top: nil, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor)
        scrollView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
