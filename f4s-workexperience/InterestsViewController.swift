//
//  InterestsViewController.swift
//  f4s-workexperience
//
//  Created by Sergiu Simon on 28/11/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class InterestsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refineSearchButton: UIButton!

    var mapModel: MapModel = MapModel()
    
    fileprivate let reuseId = "interestsCell"
    var interests: [Interest] = []
    var selectedInterests: [Interest] = [] {
        didSet {
            if selectedInterests.count > 0 {
                refineSearchButton.isEnabled = true
            } else {
                if self.initialSelectedInterests.count > 0 {
                    refineSearchButton.isEnabled = true

                } else {
                    refineSearchButton.isEnabled = false
                }
            }
        }
    }

    var initialSelectedInterests: [Interest] = []
    var currentBounds: GMSCoordinateBounds? {
        set {
            mapModel.currentBounds = currentBounds
        }
        get {
            return mapModel.currentBounds
        }
    }

    let uiIndicatorBusy = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var allCompaniesCount: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustAppearance()
        self.adjustNavigationBar()
        getInterests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        refineSearchButton.layer.cornerRadius = 10
        refineSearchButton.layer.masksToBounds = true
        refineSearchButton.adjustsImageWhenHighlighted = false
        refineSearchButton.setBackgroundColor(color: UIColor(netHex: Colors.lightGreen), forUIControlState: .highlighted)
        refineSearchButton.setBackgroundColor(color: UIColor(netHex: Colors.whiteGreen), forUIControlState: .disabled)
        refineSearchButton.setBackgroundColor(color: UIColor(netHex: Colors.mediumGreen), forUIControlState: .normal)
        refineSearchButton.setTitleColor(UIColor.white, for: .normal)
        refineSearchButton.setTitleColor(UIColor.white, for: .highlighted)
    }

    func adjustNavigationBar() {
        self.navigationItem.title = NSLocalizedString("Interests", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor(netHex: Colors.azure)
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false

        let closeButton = UIBarButtonItem(image: UIImage(named: "closeButton-white"), style: .plain, target: self, action: #selector(dismissInterestView(_:)))
        navigationItem.setLeftBarButton(closeButton, animated: false)
    }

    func getInterests() {
        guard let _ = mapModel.currentBounds else { return }
        self.startAnimating()
        mapModel.getInterestsInCurrentBounds { (interests) in
            if interests.count > 0 {
                let selectedInterestsForUser = InterestDBOperations.sharedInstance.getInterestForCurrentUser()
                self.interests = interests.filter({ $0.interestCount != 0 })
                for selectedinterest in selectedInterestsForUser {
                    if !self.interests.contains(where: { $0.uuid == selectedinterest.uuid }) {
                        self.interests.append(selectedinterest)
                    }
                }
                self.selectedInterests = selectedInterestsForUser
                self.initialSelectedInterests = selectedInterestsForUser
            }
        }

        if self.selectedInterests.count > 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseOperations.sharedInstance.getCompanyCountFromArea(startLongitude: southWestLongitude, startLatitude: southWestLatitude, endLongitude: northEastLongitude, endLatitude: northEastLatitude, interestList: self.selectedInterests, completed: {
                    count, interests in
                    DispatchQueue.main.async {
                        self.uiIndicatorBusy.stopAnimating()
                        if self.areEquals(array1: self.selectedInterests, array2: interests) {
                            self.updateResultsLabel(count: count)
                        }
                    }
                })
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseOperations.sharedInstance.getCompaniesInLocationNoLimit(startLongitude: southWestLongitude, startLatitude: southWestLatitude, endLongitude: northEastLongitude, endLatitude: northEastLatitude, completed: {
                    companies in
                    DispatchQueue.main.async {
                        self.uiIndicatorBusy.stopAnimating()
                        self.updateResultsLabel(count: companies.count)
                    }
                })
            }
        }
    }

    func updateResultsLabel(count: Int) {
        let label = UILabel()
        let resultsString = count == 1 ? " Result" : " Results"
        label.attributedText = NSAttributedString(string: "\(count)" + resultsString, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: Style.smallTextSize,
                                                   weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: UIColor.white,
        ])
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
            label.attributedText = NSAttributedString(string: resultsString, attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: Style.smallTextSize,
                                                       weight: UIFontWeightRegular),
                NSForegroundColorAttributeName: UIColor.white,
            ])
            label.sizeToFit()
            let customBarBtn = UIBarButtonItem(customView: label)

            self.navigationItem.setRightBarButtonItems([customBarBtn, UIBarButtonItem(customView: self.uiIndicatorBusy)], animated: false)
        }
    }

    func areEquals(array1: [Interest], array2: [Interest]) -> Bool {
        if array1.count != array2.count {
            return false
        }
        for i in 0 ... array2.count - 1 {
            if array1[i].uuid != array2[i].uuid {
                return false
            }
        }
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension InterestsViewController: UICollectionViewDataSource {

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return interests.count
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
        let currentInterest = interests[indexPath.row]

        cell.interestNameLabel.text = currentInterest.name
        cell.interestFrequencyLabel.text = " (\(String(currentInterest.interestCount)))"

        if !cell.isSelected && self.selectedInterests.contains(where: { $0.uuid == currentInterest.uuid }) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
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
        let selectedInterest = self.interests[indexPath.row]
        self.selectedInterests.append(selectedInterest)
        self.startAnimating()

        guard let southWestLongitude = self.currentBounds?.southWest.longitude,
            let southWestLatitude = self.currentBounds?.southWest.latitude,
            let northEastLongitude = self.currentBounds?.northEast.longitude,
            let northEastLatitude = self.currentBounds?.northEast.latitude else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            DatabaseOperations.sharedInstance.getCompanyCountFromArea(startLongitude: southWestLongitude, startLatitude: southWestLatitude, endLongitude: northEastLongitude, endLatitude: northEastLatitude, interestList: self.selectedInterests, completed: {
                count, interests in
                DispatchQueue.main.async {
                    self.uiIndicatorBusy.stopAnimating()
                    if self.areEquals(array1: self.selectedInterests, array2: interests) {
                        self.updateResultsLabel(count: count)
                    }
                }
            })
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? InterestsCollectionViewCell {
            if let text = cell.interestNameLabel.text {
                if let index = self.selectedInterests.index(where: { $0.name == text }) {
                    self.selectedInterests.remove(at: index)
                }
            }
        }
        self.startAnimating()

        guard let southWestLongitude = self.currentBounds?.southWest.longitude,
            let southWestLatitude = self.currentBounds?.southWest.latitude,
            let northEastLongitude = self.currentBounds?.northEast.longitude,
            let northEastLatitude = self.currentBounds?.northEast.latitude else {
            return
        }

        if selectedInterests.count > 0 {
            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseOperations.sharedInstance.getCompanyCountFromArea(startLongitude: southWestLongitude, startLatitude: southWestLatitude, endLongitude: northEastLongitude, endLatitude: northEastLatitude, interestList: self.selectedInterests, completed: {
                    count, interests in
                    DispatchQueue.main.async {
                        self.uiIndicatorBusy.stopAnimating()
                        if self.areEquals(array1: self.selectedInterests, array2: interests) {
                            self.updateResultsLabel(count: count)
                        }
                    }
                })
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                DatabaseOperations.sharedInstance.getCompaniesInLocationNoLimit(startLongitude: southWestLongitude, startLatitude: southWestLatitude, endLongitude: northEastLongitude, endLatitude: northEastLatitude, completed: {
                    companies in
                    DispatchQueue.main.async {
                        self.uiIndicatorBusy.stopAnimating()
                        self.updateResultsLabel(count: companies.count)
                    }
                })
            }
        }
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
        let interestStr = interests[indexPath.row].name + " (\(interests[indexPath.row].interestCount))"
        var sizeForText = getTextSize(interestStr, font: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular), maxWidth: collectionView.bounds.width)
        sizeForText.height = 40
        return sizeForText
    }

    func getTextSize(_ text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let textString = text as NSString

        let attributes = [NSFontAttributeName: font]
        let rect = textString.boundingRect(with: CGSize(width: maxWidth, height: 40), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)

        return CGSize(width: rect.width + 20, height: rect.height)
    }
}

extension InterestsViewController {

    @IBAction func refineSearchButtonTouched(_: UIButton) {
        for initialSelectedInterest in initialSelectedInterests {
            InterestDBOperations.sharedInstance.removeInterestWithId(interestUuid: initialSelectedInterest.uuid)
        }

        for selectedInterest in selectedInterests {
            InterestDBOperations.sharedInstance.saveInterest(interest: selectedInterest)
        }
        if let southWestCoordinate = self.currentBounds?.southWest, let northEastCoordinate = self.currentBounds?.northEast {
            self.mapController?.getCompaniesInLocationWithInterests(coordinates_start: southWestCoordinate, coordinates_end:
                northEastCoordinate, isNearLocation: false, shouldReposition: false)
        }
        self.dismiss(animated: true, completion: nil)
    }

    func dismissInterestView(_: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
