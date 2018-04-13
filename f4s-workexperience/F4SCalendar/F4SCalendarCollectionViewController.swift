//
//  F4SCalendarCollectionViewController.swift
//  HoursPicker2
//
//  Created by Keith Dev on 15/03/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SCalendarCollectionViewControllerDelegate {
    func calendarDidChangeRange(_ calendar: F4SCalendarCollectionViewController, firstDay: F4SCalendarDay? , lastDay: F4SCalendarDay?)
}

class F4SCalendarCollectionViewController: UICollectionViewController {
    public enum ReuseIdentifier : String {
        case dayView
    }
    
    var delegate: F4SCalendarCollectionViewControllerDelegate?
    
    private var cal: F4SCalendar = {
        return F4SCalendar()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(F4SCalendarMonthViewDayCell.self, forCellWithReuseIdentifier: ReuseIdentifier.dayView.rawValue)

        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.white
        configureFlowLayout()
        reload()
    }
    
    func configureFlowLayout() {
        let flowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = -0.5
        let frameWidth = view.frame.width / 7.0
        flowLayout.itemSize = CGSize(width: frameWidth, height: frameWidth)
        flowLayout.sectionFootersPinToVisibleBounds = true
        flowLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    var firstDay: F4SCalendarDay? {
        return cal.firstDay
    }
    
    var lastDay: F4SCalendarDay? {
        return cal.lastDay
    }
    
    func setSelection(firstDate: Date, lastDate: Date) {
        let firstDay = F4SCalendarDay(cal: cal, date: firstDate)
        let lastDay = F4SCalendarDay(cal: cal, date: lastDate)
        cal.setSelection(firstDay: firstDay, lastDay: lastDay)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cal.numberOfDisplayableMonths
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let displayMonth = cal.displayableMonth(index: section)
        return displayMonth.numberOfDaysToDisplay()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.dayView.rawValue, for: indexPath) as! F4SCalendarMonthViewDayCell

        let displayMonth = cal.displayableMonth(index: indexPath.section)
        let day = displayMonth.dayForRow(row: indexPath.row)!
        cell.configure(day: day, calendarMonth: displayMonth.month)
        cell.selectionState = F4SExtendibleSelectionState(rawValue: cal.selectionStates[day.midday]!)!
        cell.notifyDidTap = { [weak self] sender in
            guard let strongSelf = self else { return }
            // There is detailed logic in the threeTapWaltz, but basically the first tap starts a selection,
            // the second tap extends the selection, and the third tap removes the selection
            strongSelf.cal.threeTapWaltz(day: sender.day)
            collectionView.reloadData()
            strongSelf.delegate?.calendarDidChangeRange(strongSelf, firstDay: strongSelf.cal.firstDay, lastDay: strongSelf.cal.lastDay)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        default:
            assert(kind == UICollectionElementKindSectionHeader, "Unexpected kind")
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "monthHeaderViewCell", for: indexPath) as! F4SMonthHeaderView
            let displayMonth = cal.displayableMonth(index: indexPath.section)
            headerView.label.text = displayMonth.month.monthSymbol + " " + String(describing: displayMonth.month.year)
            headerView.backgroundColor = UIColor.white
            return headerView
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
 

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }

}

extension F4SCalendarCollectionViewController : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = collectionView.bounds.width/7
        let itemHeight = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
}



