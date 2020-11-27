
import UIKit

class DiscoveryTrayView : UIView {

//    lazy var thumbButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(named: "thumbScrollIndicator"), for: .normal)
//        addSubview(button)
//        button.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 44, height: 44))
//        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        return button
//    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        addSubview(tableView)
        tableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0))
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


extension DiscoveryTrayView {
    

}
