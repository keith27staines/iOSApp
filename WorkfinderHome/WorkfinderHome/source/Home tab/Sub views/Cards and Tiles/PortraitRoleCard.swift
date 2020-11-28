
import UIKit
import WorkfinderUI

class PortraitRoleCard: UIView {
    
    var tapAction: ((String) -> Void)?
    
    @objc func tapped() {
        guard let id = roleData.id else { return }
        tapAction?(id)
    }
    
    lazy var logoContainer: UIView = {
        let view = UIView()
        view.addSubview(logo)
        logo.anchor(top: view.topAnchor, leading: nil, bottom: view.bottomAnchor, trailing: nil)
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.heightAnchor.constraint(equalToConstant: 30).isActive = true
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    func makeSeparatorView() -> UIView {
        let line = UIView()
        line.widthAnchor.constraint(equalToConstant: 128).isActive = true
        line.backgroundColor = UIColor.init(white: 238/255, alpha: 1)
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        line.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        return container
    }
    
    let projectTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.init(white: 41/255, alpha: 1)
        return label
    }()
    
    let paidHeader: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.init(white: 112/255, alpha: 1)
        return label
    }()
    
    let paidAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 0/255, alpha: 1)
        return label
    }()
    
    let locationHeader: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.init(white: 101/255, alpha: 1)
        return label
    }()
    
    let location: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor.init(white: 0/255, alpha: 1)
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(WorkfinderColors.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()
    
    lazy var stack: UIStackView = {
        let topVariableSpace = UIView()
        let bottomVariableSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
                logoContainer,
                UIView.verticalSpaceView(height: 17),
                makeSeparatorView(),
                topVariableSpace,
                projectTitle,
                UIView.verticalSpaceView(height: 5),
                paidHeader,
                paidAmount,
                UIView.verticalSpaceView(height: 5),
                locationHeader,
                location,
                bottomVariableSpace,
                makeSeparatorView(),
                UIView.verticalSpaceView(height: 10),
                actionButton
            ]
        )
        topVariableSpace.heightAnchor.constraint(equalTo: bottomVariableSpace.heightAnchor).isActive = true
        stack.axis = .vertical
        stack.alignment = .fill
        stack.layoutSubviews()
        return stack
    }()
    
    let roleData: RoleData
    
    init(data: RoleData, tapAction: @escaping ((String)-> Void) ) {
        self.roleData = data
        self.tapAction = tapAction
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        configureViews()
        refreshFromData(data)
    }
    
    func refreshFromData(_ data: RoleData) {
        logo.load(urlString: data.roleLogoUrlString)
        projectTitle.text = data.projectTitle
        paidHeader.text = data.paidHeader
        paidAmount.text = data.paidAmount
        locationHeader.text = data.locationHeader
        location.text = data.location
        actionButton.setTitle(data.actionButtonText, for: .normal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureViews() {
        addSubview(stack)
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        layer.cornerRadius = 14
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(white: 227/255, alpha: 1).cgColor
        layer.shadowRadius = 60
        layer.shadowColor = UIColor.init(white: 0, alpha: 0.04).cgColor
    }
    
}


extension UIView {
    static func verticalSpaceView(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}
