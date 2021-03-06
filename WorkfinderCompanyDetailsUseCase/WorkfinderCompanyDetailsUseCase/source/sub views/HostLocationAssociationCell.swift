
import UIKit
import WorkfinderCommon
import WorkfinderUI

class HostLocationAssociationCell: UITableViewCell {
    
    static var reuseIdentifier: String = "HostLocationAssociationCell"
    
    func configureWithAssociation(_ association: HostAssociationJson,
                           summaryState: ExpandableLabelState ,
                           profileLinkTap: @escaping ((HostAssociationJson) -> Void),
                           selectAction: @escaping (HostAssociationJson) -> Void) {
        hostView.configureWith(host: association.host, association: association)
        hostView.expandableLabelState = summaryState
        hostView.profileLinkTap = profileLinkTap
        hostView.selectAction = { isSelectedView in
            var updatedAssociation = association
            updatedAssociation.isSelected.toggle()
            selectAction(updatedAssociation)
        }
    }
    
    lazy var hostView: HostLocationAssociationView = {
        return HostLocationAssociationView()
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
