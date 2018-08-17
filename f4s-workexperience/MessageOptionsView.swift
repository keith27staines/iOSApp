//
//  MessageOptionsFooterReusableView.swift
//  VITL
//
//  Created by Timea Tivadar on 8/3/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class MessageOptionsView: UICollectionReusableView {
    @IBOutlet weak var optionCollectionView: UICollectionView!
    let MessageOptionCollectionViewCellIdentifier: String = "MessageOptionCollectionViewCellIdentifier"
    var optionList: [F4SCannedResponse] = []
    var optionsToLoad: [F4SCannedResponse] = []
    var parentController: MessageContainerViewController?
    var loadTimer = Timer()
    var deleteTimer = Timer()
    var loadCellIsInProgress: Bool = false
    var deleteCellsInProgress: Bool = false
    var shouldDeleteCells: Bool = false
    var optionCollectionFlowLayout: MessageOptionsCollectionFlowLayout?
    weak var messageOptionFlowProtocol: MessageOptionFlowProtocol?
    let lock = NSLock()
    var removeAnswerCompleted: () -> Void = {  }
    let animationTime: TimeInterval = 0.2

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibView = Bundle.main.loadNibNamed("MessageOptionsView", owner: self, options: nil)?[0] as! UIView
        nibView.frame = self.bounds
        nibView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.addSubview(nibView)

        self.backgroundColor = UIColor.white
        self.optionCollectionFlowLayout = MessageOptionsCollectionFlowLayout(optionsCollectionView: self.optionCollectionView)
        self.optionCollectionFlowLayout?.invalidateLayout()
        self.optionCollectionView.setCollectionViewLayout(self.optionCollectionFlowLayout!, animated: false)
        self.messageOptionFlowProtocol = self.optionCollectionFlowLayout

        self.optionCollectionView.register(MessageOptionCollectionViewCell.self, forCellWithReuseIdentifier: MessageOptionCollectionViewCellIdentifier)
        self.optionCollectionView.delegate = self
        self.optionCollectionView.dataSource = self

        self.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
    }

    func loadMessageOptions(options: [F4SCannedResponse], parentController: UIViewController) {
        self.optionList = options
        self.parentController = parentController as? MessageContainerViewController

        loadTimer.invalidate()
        loadTimer = Timer.scheduledTimer(timeInterval: animationTime, target: self, selector: #selector(insertCells), userInfo: nil, repeats: true)
        self.optionCollectionFlowLayout?.setCurrentOptionList(options: self.optionList)
        self.optionCollectionView.isUserInteractionEnabled = true
        //   print("load cells")
        synchronized(lockable: lock, criticalSection: {
            self.loadCellIsInProgress = true
            self.deleteCellsInProgress = false
        })
    }

    func removeOptions(completed: @escaping () -> Void) {
        if self.optionsToLoad.count > 0 {
            self.removeAnswerCompleted = completed
            self.optionCollectionView.isUserInteractionEnabled = false
            var loadCellStatus: Bool = false
            synchronized(lockable: lock) {
                loadCellStatus = self.loadCellIsInProgress
            }
            if !loadCellStatus {
                deleteTimer.invalidate()
                deleteTimer = Timer.scheduledTimer(timeInterval: animationTime, target: self, selector: #selector(deleteCells), userInfo: nil, repeats: true)
                // print("delete cells")
                synchronized(lockable: lock, criticalSection: {
                    self.deleteCellsInProgress = true
                    self.shouldDeleteCells = false
                })
            } else {
                //  print("should delete cells but load is in progress")
                synchronized(lockable: lock, criticalSection: {
                    self.shouldDeleteCells = true
                    self.deleteCellsInProgress = false
                })
            }
        } else {
            completed()
        }
    }

    @objc func deleteCells() {
        if self.optionsToLoad.count > 0 {
            self.messageOptionFlowProtocol?.shouldAnimateCells(true)
            let lastCellIndexPath = IndexPath(item: self.optionsToLoad.count - 1, section: 0)
            //  print("delete row")
            // print(lastCellIndexPath)
            self.optionsToLoad.removeLast()
            self.optionCollectionView.deleteItems(at: [lastCellIndexPath])
        } else {
            //  print("done delete")
            deleteTimer.invalidate()
            self.removeAnswerCompleted()
            synchronized(lockable: lock, criticalSection: {
                self.deleteCellsInProgress = false
            })
        }
    }

    @objc func insertCells() {
        let currentIndex = self.optionsToLoad.count
        self.messageOptionFlowProtocol?.shouldAnimateCells(true)
        if currentIndex < self.optionList.count {
            //            print("insert cell")
            //            print(currentIndex)
            self.optionsToLoad.append(self.optionList[currentIndex])
            self.optionCollectionView.insertItems(at: [IndexPath(item: currentIndex, section: 0)])
        } else {
            // print("load done")
            loadTimer.invalidate()
            var shouldDelete: Bool = false
            synchronized(lockable: lock, criticalSection: {
                self.loadCellIsInProgress = false
                shouldDelete = self.shouldDeleteCells
            })
            if shouldDelete {
                deleteTimer.invalidate()
                deleteTimer = Timer.scheduledTimer(timeInterval: animationTime, target: self, selector: #selector(deleteCells), userInfo: nil, repeats: true)
                //  print("delete after load done")
                synchronized(lockable: lock, criticalSection: {
                    self.deleteCellsInProgress = true
                    self.shouldDeleteCells = false
                })
            }
        }
    }
}

class MessageOptionsCollectionFlowLayout: UICollectionViewFlowLayout, MessageOptionFlowProtocol {
    fileprivate var optionsCollectionView: UICollectionView?
    fileprivate var optionList: [F4SCannedResponse]?
    fileprivate var shouldAnimateCells: Bool = true

    init(optionsCollectionView: UICollectionView) {
        super.init()
        self.optionsCollectionView = optionsCollectionView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setCurrentOptionList(options: [F4SCannedResponse]) {
        self.optionList = options
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        guard let options = self.optionList else {
            return attributes
        }
        guard let optionCollection = optionsCollectionView else {
            return attributes
        }

        if shouldAnimateCells {
            let cellSize = MessageOptionHelper.sharedInstance.getCellSize(options: options, index: itemIndexPath.row)
            var x: CGFloat = 0
            if options.count > itemIndexPath.row {
                x = itemIndexPath.row % 2 == 0 ? 5 : cellSize.width + 10
            } else {
                x = 5
            }
            attributes?.frame = CGRect(x: x + 5, y: optionCollection.frame.height, width: cellSize.width, height: cellSize.height)
        }
        return attributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes: UICollectionViewLayoutAttributes? = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        guard let options = self.optionList else {
            return attributes
        }
        guard let optionCollection = optionsCollectionView else {
            return attributes
        }

        if shouldAnimateCells {
            let cellSize = MessageOptionHelper.sharedInstance.getCellSize(options: options, index: itemIndexPath.row)
            var x: CGFloat = 0
            if options.count > itemIndexPath.row {
                x = itemIndexPath.row % 2 == 0 ? 5 : cellSize.width + 10
            } else {
                x = 5
            }
            attributes?.frame = CGRect(x: x, y: optionCollection.frame.height, width: cellSize.width, height: cellSize.height)
        }
        return attributes
    }

    func shouldAnimateCells(_ shouldAnimate: Bool) {
        self.shouldAnimateCells = shouldAnimate
    }
}

// MARK: - data source, delegate
extension MessageOptionsView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.optionsToLoad.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageOptionCollectionViewCellIdentifier, for: indexPath) as? MessageOptionCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.answerLabel.text = self.optionsToLoad[indexPath.row].value
        cell.answerLabel.textColor = skin?.primaryButtonSkin.textColor.uiColor
        cell.answerLabel.backgroundColor = skin?.primaryButtonSkin.backgroundColor.uiColor
        cell.answerLabel.layer.cornerRadius = 10
        cell.answerLabel.layer.masksToBounds = true
        cell.answerLabel.numberOfLines = 0
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return MessageOptionHelper.sharedInstance.getCellSize(options: self.optionList, index: indexPath.row)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 5
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // send the response
        self.parentController?.didSelectAnswer(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MessageOptionCollectionViewCell {
            cell.answerLabel.backgroundColor = UIColor(netHex: Colors.lightGreen)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MessageOptionCollectionViewCell {
            cell.answerLabel.backgroundColor = UIColor(netHex: Colors.mediumGreen)
        }
    }
}

protocol MessageOptionFlowProtocol: class {
    func shouldAnimateCells(_ shouldAnimate: Bool)
}
