import UIKit
import WorkfinderUI

class HorizontallyScrollingCell: UITableViewCell {
    private var verticalMargin = CGFloat(20)
    private var scrollViewHeight = CGFloat(45)
    
    func adjustMarginsAndGutter(verticalMargin: CGFloat = 20, scrollViewHeight: CGFloat = 45, gutter: CGFloat) {
        self.verticalMargin = verticalMargin
        self.scrollViewHeight = scrollViewHeight
        scrollViewHeightConstraint.constant = scrollViewHeight
        self.gutter = gutter
    }
    
    var gutter: CGFloat = 20 {
        didSet {
            scrollContentStack.spacing = gutter
            leftInsetConstraint.constant = gutter/2.0
            rightInsetConstraint.constant = -gutter/2.0
        }
    }

    var cardCount: Int = 0
    func addCard(_ card: UIView) {
        scrollContentStack.addArrangedSubview(card)
        cardCount += 1
        pageControl.numberOfPages = 1 + (cardCount - 1) / 2
    }
    
    func clear() {
        scrollContentStack.arrangedSubviews.forEach { (view) in
            scrollContentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        cardCount = 0
    }
    
    var isPagingEnabled: Bool = false {
        didSet {
            scrollView.isPagingEnabled = isPagingEnabled
            switch isPagingEnabled {
            case false:
                scrollAndPageControlStack.removeArrangedSubview(pageControl)
            case true:
                scrollAndPageControlStack.addArrangedSubview(pageControl)
            }
        }
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        guard isPagingEnabled else { return }
        layoutSubviews()
    }
    
    lazy var scrollAndPageControlStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [scrollView]
        )
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 30
        return stack
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        control.pageIndicatorTintColor = UIColor.init(white: 216/255, alpha: 1)
        control.currentPageIndicatorTintColor = WorkfinderColors.primaryColor
        control.numberOfPages = 5
        control.currentPage = 0
        control.heightAnchor.constraint(equalToConstant: 10).isActive = true
        control.addTarget(self, action: #selector(changePage), for: .valueChanged)
        control.hidesForSinglePage = true
        return control
    }()
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = contentView.heightAnchor.constraint(equalTo: scrollAndPageControlStack.heightAnchor, multiplier: 1, constant: 2*verticalMargin)
        return constraint
    }()
    
    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: scrollViewHeight)
        return constraint
    }()
        
    private lazy var scrollContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    private lazy var leftInsetConstraint: NSLayoutConstraint = {
        let constraint = scrollContentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
        constraint.priority = .defaultHigh
        return constraint
    }()
    
    private lazy var rightInsetConstraint: NSLayoutConstraint = {
        let constraint = scrollContentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0)
        constraint.priority = .defaultHigh
        return constraint
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        contentView.addSubview(scrollAndPageControlStack)
        scrollAndPageControlStack.anchor(top: nil, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        scrollAndPageControlStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        scrollView.addSubview(scrollContentStack)
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollContentStack.anchor(top: scrollView.topAnchor, leading: nil, bottom: scrollView.bottomAnchor, trailing: nil)
        scrollViewHeightConstraint.isActive = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        heightConstraint.isActive = true
        leftInsetConstraint.isActive = true
        rightInsetConstraint.isActive = true
    }
    
    @objc func changePage(sender: UIPageControl) -> () {
        let x = CGFloat(sender.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }


}

extension HorizontallyScrollingCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
