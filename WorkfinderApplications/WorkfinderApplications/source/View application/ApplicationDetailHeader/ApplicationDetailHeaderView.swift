//
//  ApplicationDetailHeaderView.swift
//  WorkfinderApplications
//
//  Created by Keith on 23/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class ApplicationDetailHeaderView: UIView {
    
    let defaultLogoSize = CGSize(width: 80, height: 80)
    
    func configureWith(_ data: ApplicationDetailHeaderData?) {
        projectName.text = data?.projectName
        companyName.text = data?.companyName
        let defaultImage = UIImage.from(size: defaultLogoSize, string: data?.companyLogoDefaultText ?? "?", backgroundColor: WFColorPalette.readingGreen)
        companyLogo.load(urlString: data?.companyLogoUrlString, defaultImage: defaultImage)
    }
    
    private lazy var logoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [companyLogo, UIView()])
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var companyLogo: WFSelfLoadingImageViewWithHeight = {
        let view = WFSelfLoadingImageViewWithHeight(height: defaultLogoSize.height)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return view
    }()
    
    private lazy var projectName: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.sectionTitle
        label.applyStyle(style)
        return label
    }()
    
    private lazy var companyName: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.bodyTextRegular
        label.applyStyle(style)
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            logoStack,
            projectName,
            companyName
        ])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
