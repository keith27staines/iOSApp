//
//  CarouselTile.swift
//  WorkfinderApplications
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

struct OfferData {
    
    enum OfferType {
        
        case interview(id: Int)
        case placement(uuid: String)
        
        var prize: String {
            switch self {
            case .interview: return " has invited you to an interview"
            case .placement: return " has offered you a placement"
            }
        }
        
        var actionButtonText: String {
            switch self {
            case .interview:
                return "Respond to Offer"
            case .placement:
                return "Respond to Invitation"
            }
        }
    }
    
    var offerType: OfferType
    var imageUrlString: String?
    var defaultImageText: String?
    var buttonAction: (() -> Void)?
    
    var buttonState: WFButton.State
    private var hostName: String?
    private var companyName: String?
    
    var buttonText: String { offerType.actionButtonText }
    
    var text: String? {
        let host = hostName ?? ""
        let company = companyName ?? ""
        if host.isEmpty && company.isEmpty {
            return "This company has \(offerType.prize)"
        }
        if host.isEmpty {
            return "\(company) \(offerType.prize)"
        }
        if company.isEmpty {
            return "\(host) \(offerType.prize)"
        }
        return "\(host) at \(company) \(offerType.prize)"
    }

    init(offerType: OfferType,
         imageUrlString: String?,
         defaultImageText: String?,
         buttonState: WFButton.State = .normal,
         hostName: String?,
         companyName: String?,
         buttonAction: (OfferData) -> Void
    ) {
        
    }
}

class OfferCell: UICollectionViewCell, CarouselCellProtocol {
    typealias CellData = OfferData
    static var identifier = "OffersCell"
    
    func configure(with data: OfferData) {
        let defaultImage = UIImage.makeImageFromFirstCharacter(data.defaultImageText ?? "?", size: CGSize(width: imageHeight, height: imageHeight))
        imageView.load(urlString: data.imageUrlString, defaultImage: defaultImage)
        button.text = data.buttonText
        button.state = data.buttonState
        textLabel.text = data.text
    }

    var imageHeight: CGFloat = 46
    var buttonHeight: NSLayoutConstraint?
    var frameHeight: CGFloat = 100
    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
    
    private lazy var imageView: WFSelfLoadingImageView = {
        let view = WFSelfLoadingImageView()
        view.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        var style = WFTextStyle.labelTextRegular
        style.color = UIColor(red: 0.008, green: 0.188, blue: 0.161, alpha: 1)
        label.applyStyle(style)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: WFButton = {
        let button = WFButton(heightClass: .larger)
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let variableSpace = UIView()
        let stack = UIStackView(arrangedSubviews: [
                imageView,
                textLabel,
                variableSpace,
                button
            ]
        )
        stack.axis = .vertical
        stack.spacing = halfspace
        return stack
    }()
    
    private lazy var tile: UIView = {
        let view = UIView()
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: space, left: space, bottom: space, right: space))

        return view
    }()
    
    func configureViews() {
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }

    init(frameHeight: CGFloat, imageHeight: CGFloat, buttonHeight: CGFloat) {
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


