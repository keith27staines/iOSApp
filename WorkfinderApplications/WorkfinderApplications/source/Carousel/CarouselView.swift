//
//  Carousel.swift
//  WorkfinderApplications
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import UIKit
import WorkfinderUI

protocol CarouselCellProtocol: UICollectionViewCell {
    associatedtype CellData
    static var identifier: String { get }
    func configure(with data: CellData)
}

class CarouselView<CarouselCell: CarouselCellProtocol>: UIView {
    
    var cellSize: CGSize
    var cellData = [[CarouselCell.CellData]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    var currentPage: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        addSubview(collection)
        collection.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.backgroundColor = .clear
        collection.dataSource = self as? UICollectionViewDataSource
        collection.delegate = self as? UICollectionViewDelegate
        return collection
    }()
    
    func configure(_ cell: CarouselCell, withDataForIndexPath indexPath: IndexPath) {
        let data = cellData[indexPath.section][indexPath.row]
        cell.configure(with: data)
    }
    
    func registerCell(cellClass: AnyClass, withIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    override func layoutSubviews() {
        let cellWidth = cellSize.width
        let cellHeight = cellSize.height
        let cellPadding = (frame.width - cellWidth) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: cellWidth, height: cellHeight)
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
        carouselLayout.minimumLineSpacing = frame.width - cellWidth
        collectionView.collectionViewLayout = carouselLayout
        collectionView.layoutSubviews()
    }
    
    private func configureViews() {

    }
    
    init(cellSize: CGSize) {
        self.cellSize = cellSize
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections() -> Int {
        cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { cellData[section].count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = cellData[indexPath.section][indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as? CarouselCell
        else { return UICollectionViewCell() }
        cell.configure(with: data)
        return cell
    }
    
    // MARK:- UICollectionViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
}

// MARK: - Helpers
private extension CarouselView {
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        return currentPage
    }
}
