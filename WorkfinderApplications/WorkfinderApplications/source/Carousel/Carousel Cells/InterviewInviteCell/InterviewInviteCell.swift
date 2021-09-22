//
//  InterviewInviteCell.swift
//  WorkfinderApplications
//
//  Created by Keith on 13/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class InterviewInviteCell: UICollectionViewCell, CarouselCellProtocol {

    typealias CellData = InterviewInviteData
    static var identifier = "InterviewInviteCell"
    private var _size = CGSize.zero
    
    func configure(with data: InterviewInviteData, size: CGSize) {
        _size = size
        tile.configure(with: data)
    }
        
    override var intrinsicContentSize: CGSize {
        _size
    }
    
    lazy var tile = InterviewInviteTile()
    
    func configureViews() {
        contentView.addSubview(tile)
        tile.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



