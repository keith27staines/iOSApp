//
//  AMPAccountSectionCell.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 09/04/2021.
//

import UIKit
import WorkfinderCommon

struct AccountSectionInfo {
    var image: UIImage?
    var title: String?
    var progress: Float? { calculator?.progress ?? 0 }
    var calculator: ProgressCalculatorProtocol?
}

class SocialMediaCell: UITableViewCell {
    static let reuseIdentifier = "SocialMediaCell"
    static let defaultImage: UIImage? = UIImage(named: "ui-linkedin-icon")
    
    func configureWithLinkedinDataConnection(_ data: LinkedinConnectionData?) {
        imageView?.image = UIImage(named: "ui-linkedin-icon")
        textLabel?.text = "LinkedIn"
        detailTextLabel?.text = "View or connect your LinkedIn account"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AMPAccountSectionCell: UITableViewCell {
    
    static let reuseIdentifier = "accountSectionCell"
    static let defaultImage: UIImage? = UIImage(named: "avatar")
    
    func configureWith(_ info: AccountSectionInfo) {
        _icon.image = info.image
        _title.text = info.title
        _progress.setFractionComplete(CGFloat(info.progress ?? 0))
        _progress.isHidden = info.progress == 0
    }
    
    private lazy var _icon: UIImageView = {
        let view = UIImageView(image: AMPHeaderCell.defaultImage)
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.layer.cornerRadius = 0
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var _title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        return label
    }()
    
    private lazy var _progress: FractionCompleteView = {
        let view = FractionCompleteView()
        view.widthAnchor.constraint(equalToConstant: 54).isActive = true
        view.setFractionComplete(0)
        return view
    }()
    
    private lazy var _textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [_title])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        return stack
    }()
    
    private lazy var _mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [_icon, _textStack, _progress])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 14
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(_mainStack)
        _mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 26, bottom: 12, right: 20))
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FractionCompleteView: UIView {
    var width: CGFloat = 54
    var height: CGFloat = 10
    var min = 0 { didSet { setCornerRadius() } }
    var max = 100
    private var _fractionComplete: CGFloat = 0
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var progressConstraint: NSLayoutConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame:CGRect.zero)
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
        backgroundColor = UIColor.init(white: 0.85, alpha: 1)
        addSubview(bar)
        progressConstraint = bar.widthAnchor.constraint(equalToConstant: 0)
        progressConstraint?.isActive = true
        bar.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil)
        setCornerRadius()
        setFractionComplete(0)
    }
    
    var barColor: UIColor = UIColor(red:0.29, green:0.16, blue:0.51, alpha:1)
    { didSet { bar.backgroundColor = barColor } }
        
    lazy private var bar: UIView = {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = barColor
        progressConstraint?.isActive = true
        return bar
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setFractionComplete(_fractionComplete)
    }
    
    func setFractionComplete(_ fractionComplete: CGFloat) {
        _fractionComplete = fractionComplete
        let f = fractionComplete 
        progressConstraint?.constant = f * width
    }
    
    func setCornerRadius() {
        layer.cornerRadius = height/2.0
        bar.layer.cornerRadius = layer.cornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
