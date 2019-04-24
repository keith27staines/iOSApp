//
//  InterestsViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 28/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit
import WorkfinderCommon

protocol InterestsViewControllerDelegate {
    func interestsViewController(_ vc: InterestsViewController, didChangeSelectedInterests: F4SInterestSet)
}

class InterestsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refineSearchButton: UIButton!
    var visibleBounds: GMSCoordinateBounds!
    
    /// The map model containing all companies, unfiltered by any interests
    var mapModel: MapModel!
    
    fileprivate let reuseId = "interestsCell"
    
    /// The list of interests the user can select from, which includes interests they have selected previously plus any of the interests of companies within visibleBounds
    private (set) var interestsToDisplay: [F4SInterest] = [F4SInterest]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var delegate: InterestsViewControllerDelegate!
    
    var interestsCount: F4SInterestCounts = F4SInterestCounts()

    /// The union of all interests of all companies within visible bounds
    var interestsInBounds: F4SInterestSet!
    
    /// Interests that the user originally had selected to use as filters on view load
    var originallySelectedInterests: F4SInterestSet = F4SInterestSet()
    
    
    /// Interests that the user currently has actively selected to use as filters
    var selectedInterests: F4SInterestSet! {
        didSet {
            refineSearchButton.isEnabled = (selectedInterests == originallySelectedInterests) ? false : true
        }
    }

    let uiIndicatorBusy = UIActivityIndicatorView(style: .white)

    var interestsModel: InterestsModel {
        return mapModel.interestsModel
    }
    typealias InterestCountResults = (Int,F4SInterestCounts)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearance()
        adjustNavigationBar()
        applyStyle()
        startAnimating()
        originallySelectedInterests = InterestDBOperations.sharedInstance.interestsForCurrentUser()
        selectedInterests = originallySelectedInterests
        mapModel.getInterestsInBounds(visibleBounds) { (interestsInBounds) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.interestsInBounds = interestsInBounds
                let interests = strongSelf.combineInterestsAsSortedList(interestSubsets: interestsInBounds,strongSelf.selectedInterests)
                strongSelf.interestsToDisplay = interests
                strongSelf.getUpdatedCounts(completion: { (counts) in
                    DispatchQueue.main.async {
                        strongSelf.interestsCount = counts.1
                        strongSelf.updateUIWithCounts(counts: counts, completion: nil)
                        strongSelf.updateUITotals(counts: counts, completion: nil)
                        strongSelf.uiIndicatorBusy.stopAnimating()
                    }
                })
            }
        }
    }
    
    func applyStyle() {
        let skinner = Skinner()
        skinner.apply(buttonSkin: skin?.primaryButtonSkin, to: refineSearchButton)
        styleNavigationController()
    }
    
    func updateUITotals(completion: (() -> Void)?) {
        getUpdatedCounts() { [weak self] counts in
            self?.updateUITotals(counts: counts, completion: completion)
        }
    }
    
    func updateUITotals(counts: InterestCountResults, completion: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateResultsLabel(count: counts.0)
            completion?()
        }
    }
    
    func updateUIWithLatestCounts(completion: (() -> Void)?) {
        getUpdatedCounts() { [weak self] counts in
            self?.updateUIWithCounts(counts: counts, completion: completion)
        }
    }
    
    func updateUIWithCounts(counts: InterestCountResults, completion: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.interestsToDisplay.sort(by: { (interest1, interest2) -> Bool in
                if strongSelf.selectedInterests.contains(interest1) && !strongSelf.selectedInterests.contains(interest2) {
                    return true
                }
                if strongSelf.selectedInterests.contains(interest2) && !strongSelf.selectedInterests.contains(interest1) {
                    return false
                }
                let count1 = strongSelf.interestsCount[interest1] ?? 0
                let count2 = strongSelf.interestsCount[interest2] ?? 0
                if count1 > count2 {
                    return true
                }
                if count1 < count2 {
                    return false
                }
                return interest1.name.lowercased() < interest2.name.lowercased()
            })
            strongSelf.collectionView.reloadData()
            completion?()
        }
    }

    func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
        return true
    }
}

// MARK: - UI Setup
extension InterestsViewController {

    func adjustAppearance() {
        let customLayout = CustomViewFlowLayout()
        collectionView.collectionViewLayout = customLayout
        collectionView.allowsMultipleSelection = true
        collectionView.clipsToBounds = true
    }

    func adjustNavigationBar() {
        self.navigationItem.title = NSLocalizedString("Interests", comment: "")
        let closeButton = UIBarButtonItem(image: UIImage(named: "closeButton-white"), style: .plain, target: self, action: #selector(dismissInterestView(_:)))
        navigationItem.setLeftBarButton(closeButton, animated: false)
    }

    func updateResultsLabel(count: Int) {
        let label = UILabel()
        let resultsString = count == 1 ? " Result" : " Results"
        label.attributedText = NSAttributedString(string: "\(count)" + resultsString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Style.smallTextSize,weight: UIFont.Weight.regular),
            NSAttributedString.Key.foregroundColor: UIColor.white])
        label.sizeToFit()
        let customBarBtn = UIBarButtonItem(customView: label)
        self.navigationItem.setRightBarButton(customBarBtn, animated: true)
    }

    func startAnimating() {
        DispatchQueue.main.async {
            self.uiIndicatorBusy.isHidden = false
            self.uiIndicatorBusy.startAnimating()

            let label = UILabel()
            let resultsString = "Results"
            label.attributedText = NSAttributedString(
                string: resultsString,
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Style.smallTextSize, weight: UIFont.Weight.regular), NSAttributedString.Key.foregroundColor: UIColor.white])
            label.sizeToFit()
            let customBarBtn = UIBarButtonItem(customView: label)

            self.navigationItem.setRightBarButtonItems([customBarBtn, UIBarButtonItem(customView: self.uiIndicatorBusy)], animated: false)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension InterestsViewController: UICollectionViewDataSource {

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return interestsToDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as? InterestsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView!.backgroundColor = UIColor(netHex: Colors.powderBlue)
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(netHex: Colors.pinkishGrey).cgColor
        cell.layer.cornerRadius = 5
        let currentInterest = interestsToDisplay[indexPath.row]
        let count = interestsCount[currentInterest] ?? 0
        cell.interestNameLabel.text = currentInterest.name
        cell.interestFrequencyLabel.text = " (\(String(count)))"

        if !cell.isSelected && self.selectedInterests.contains(where: { $0.uuid == currentInterest.uuid }) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition())
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension InterestsViewController: UICollectionViewDelegate {

    func collectionView(_: UICollectionView, shouldHighlightItemAt _: IndexPath) -> Bool {
        return true
    }

    func collectionView(_: UICollectionView, shouldSelectItemAt _: IndexPath) -> Bool {
        return true
    }

    func collectionView(_: UICollectionView, shouldDeselectItemAt _: IndexPath) -> Bool {
        return true
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let interest = interestsToDisplay[indexPath.row]
        selectedInterests.insert(interest)
        updateUITotals(completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let interest = interestsToDisplay[indexPath.row]
        selectedInterests.remove(interest)
        updateUITotals(completion: nil)
    }
}

extension InterestsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return CGFloat(10)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return CGFloat(10)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interest = interestsToDisplay[indexPath.row]
        let count = interestsCount[interest] ?? 0
        let interestStr = interest.name + " (\(count))"
        var sizeForText = getTextSize(interestStr, font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular), maxWidth: collectionView.bounds.width)
        sizeForText.height = 40
        return sizeForText
    }

    func getTextSize(_ text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let textString = text as NSString

        let attributes = [NSAttributedString.Key.font: font]
        let rect = textString.boundingRect(with: CGSize(width: maxWidth, height: 40), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)

        return CGSize(width: rect.width + 20, height: rect.height)
    }
}

extension InterestsViewController {

    @IBAction func refineSearchButtonTouched(_: UIButton) {
        let interestsToSave = selectedInterests.subtracting(originallySelectedInterests)
        let interestsToRemove = originallySelectedInterests.subtracting(selectedInterests)
        for interest in interestsToRemove {
            InterestDBOperations.sharedInstance.removeUserInterestWithUuid(interest.uuid)
        }
        for interest in interestsToSave {
            InterestDBOperations.sharedInstance.saveInterest(interest)
        }
        delegate?.interestsViewController(self, didChangeSelectedInterests: selectedInterests)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func dismissInterestView(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- helpers
extension InterestsViewController {
    
    /// Gets the count of companies having at least one of the selected interests, and the count of companies for each interest individually
    func getUpdatedCounts(completion: @escaping (InterestCountResults) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let visibleBounds = strongSelf.visibleBounds!
            let selectedInterests = strongSelf.selectedInterests!
            let interestsToDisplay = F4SInterestSet(strongSelf.interestsToDisplay)
            strongSelf.mapModel.getCompanyPinSet(for: visibleBounds) { pins in
                let countsResults = strongSelf.interestsModel.interestCounts(
                    displayedInterests: interestsToDisplay,
                    selectedInterests: selectedInterests,
                    companyPins: pins)
                DispatchQueue.main.async {
                    completion(countsResults)
                }
            }
        }
    }

    
    /// Returns an array formed from the union of the specified sets of interests.
    func combineInterestsAsSortedList(interestSubsets: F4SInterestSet...) -> [F4SInterest] {
        var combinedSet: F4SInterestSet = F4SInterestSet()
        for interestSubset in interestSubsets {
            combinedSet = combinedSet.union(interestSubset)
        }
        return [F4SInterest](combinedSet)
    }
}
