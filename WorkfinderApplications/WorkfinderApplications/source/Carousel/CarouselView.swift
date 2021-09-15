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
    func configure(with data: CellData, size: CGSize)
}

class CarouselView<CarouselCell: CarouselCellProtocol>: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var cellSize: CGSize
    
    var cellData = [[CarouselCell.CellData]]() {
        didSet {
            collectionView.reloadData()
            stepper.pageCount = cellData[0].count
        }
    }
    var currentPage: Int {
        get { stepper.currentPage }
        set { stepper.currentPage = newValue }
    }
    let cellPadding = CGFloat(8)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Carousel title"
        var style = WFTextStyle.sectionTitle
        style.color = WFColorPalette.offBlack
        label.applyStyle(style)
        return label
    }()
    
    private lazy var stepper:WFPageControl = {
        let view = WFPageControl( height: 36) {
            
        } rightAction: {
            
        }

        var style = WFTextStyle.smallLabelTextRegular
        style.color = WFColorPalette.offBlack
        view.applyStyle(style)
        return view
    }()
    
    lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView(),
            stepper
        ])
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headerStack,
            collectionView
        ])
        stack.axis = .vertical
        stack.spacing = WFMetrics.standardSpace
        return stack
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = Layout(cellPadding: cellPadding, cellSize: cellSize)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.decelerationRate = .fast
        return collection
    }()
    
    func configure(_ cell: CarouselCell, withDataForIndexPath indexPath: IndexPath) {
        let data = cellData[indexPath.section][indexPath.row]
        cell.configure(with: data, size: cellSize)
    }
    
    func registerCell(cellClass: AnyClass, withIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    private func configureViews() {
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    init(cellSize: CGSize, title: String) {
        self.cellSize = cellSize
        super.init(frame: .zero)
        configureViews()
        titleLabel.text = title
        collectionView.heightAnchor.constraint(equalToConstant: cellSize.height).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections() -> Int {
        cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = cellData[indexPath.section][indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.identifier, for: indexPath) as? CarouselCell
        else { return UICollectionViewCell() }
        cell.configure(with: data, size: cellSize)
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

class Layout: UICollectionViewFlowLayout {
    
    let cellPadding: CGFloat
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return CGPoint.zero }
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x
        let targetRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0), size: collectionView.bounds.size)

        for layoutAttributes in super.layoutAttributesForElements(in: targetRect)! {
            let itemOffset = layoutAttributes.frame.origin.x
            if (abs(itemOffset - horizontalOffset) < abs(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
    init(cellPadding: CGFloat, cellSize: CGSize) {
        self.cellPadding = cellPadding
        super.init()
        self.itemSize = cellSize
        self.minimumInteritemSpacing = cellPadding;
        self.minimumLineSpacing = cellPadding;
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: 0, left: cellPadding, bottom: 0, right: cellPadding + cellSize.width/2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
