
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HostCell: UITableViewCell {
    
    static var reuseIdentifier: String = "HostCell"
    
    func configureWithHost(_ host: F4SHost,
                           summaryState: ExpandableLabelState ,
                           profileLinkTap: @escaping ((F4SHost) -> Void),
                           selectAction: @escaping (F4SHost) -> Void) {
        hostView.host = host
        hostView.expandableLabelState = summaryState
        hostView.profileLinkTap = profileLinkTap
        hostView.selectAction = { isSelectedView in
            var updatedHost = host
            updatedHost.isSelected.toggle()
            selectAction(updatedHost)
        }
    }
    
    lazy var hostView: HostView = {
        return HostView()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(hostView)
        hostView.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
