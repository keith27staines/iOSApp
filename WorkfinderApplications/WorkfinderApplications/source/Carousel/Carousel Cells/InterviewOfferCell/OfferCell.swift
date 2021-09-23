//
//  CarouselTile.swift
//  WorkfinderApplications
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

class OfferCell: UICollectionViewCell, CarouselCellProtocol {
    typealias CellData = OfferTileData
    static var identifier = "InterviewOfferCell"
    private var _size = CGSize(width: 0, height: 0)
        
    func configure(with data: OfferTileData, size: CGSize) {
        _size = size
        tile.configure(with: data)
    }

    let space = WFMetrics.standardSpace
    let halfspace = WFMetrics.halfSpace
    
    override var intrinsicContentSize: CGSize {
        _size
    }
    
    private lazy var tile: OfferTile = OfferTile()
    
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


