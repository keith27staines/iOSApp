//
//  CompanyPeopleViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit
import WorkfinderCommon
import WorkfinderUI

fileprivate let cardAspectRatio: CGFloat = 1.3

protocol CompanyPeopleViewControllerDelegate {
    func companyPeopleViewController(_ controller: CompanyPeopleViewController, didSelectPerson: PersonViewData?)
    func companyPeopleViewController(_ controller: CompanyPeopleViewController, showLinkedIn: PersonViewData)
}

class CompanyPeopleViewController: CompanySubViewController {
    
    override init(viewModel: CompanyViewModel, pageIndex: CompanyViewModel.PageIndex) {
        super.init(viewModel: viewModel, pageIndex: pageIndex)
        viewModel.selectedPersonIndexDidChange = { index in
            self.selectedPersonIndex = index
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func refresh() {
        let index = viewModel.selectedPersonIndex
        viewModel.selectedPersonIndex = nil
        peopleCollectionView.reloadData()
        viewModel.selectedPersonIndex = index
    }
    
    fileprivate var standardWidth: CGFloat {
        let viewWidth = view.frame.width / 2.5
        return viewWidth > 140 ? viewWidth : 140
    }
    
    fileprivate var standardHeight: CGFloat { return self.standardWidth * cardAspectRatio }
    fileprivate var expandedWidth: CGFloat { return 0.9 * self.view.frame.width }
    fileprivate var expandedHeight: CGFloat { return self.standardHeight }
    
    fileprivate var halfWidthSize: CGSize { return CGSize(width: self.standardWidth/2, height: self.standardHeight) }
    fileprivate var standardCardSize: CGSize { return CGSize(width: standardWidth, height: standardHeight) }
    fileprivate var expandedCardSize: CGSize { return CGSize(width: expandedWidth, height: expandedHeight) }
    
    
    func animateDeselectPerson() {
        guard let index = selectedPersonIndex, let currentlySelectedCell = peopleCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PersonCollectionViewCell else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            currentlySelectedCell.highlightedBorder = false
            self.peopleCollectionView.collectionViewLayout.invalidateLayout()
        }) { (success) in
            guard self.viewModel.people.count > 0 else { return }
            self.peopleCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func animateSelectPerson() {
        guard let index = selectedPersonIndex, let currentlySelectedCell = peopleCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? PersonCollectionViewCell else {
            bioView.personData = nil
            peopleCollectionView.isScrollEnabled = true
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.peopleCollectionView.collectionViewLayout.invalidateLayout()
            currentlySelectedCell.highlightedBorder = true
        }) { (success) in
            guard self.viewModel.people.count > 0 else { return }
            self.peopleCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
        bioView.personData = viewModel.people[index]
        peopleCollectionView.isScrollEnabled = false
    }
    
    var selectedPersonIndex: Int? = nil {
        willSet { animateDeselectPerson() }
        didSet { animateSelectPerson() }
    }
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return layout
    }()
    
    lazy var peopleCollectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.register(PersonCollectionViewCell.self, forCellWithReuseIdentifier: PersonCollectionViewCell.reuseIdentifier)
        view.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        view.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        view.backgroundColor = UIColor.white
        view.allowsSelection = true
        view.isPagingEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()

    lazy var bioView: PersonBioView = {
        let view = PersonBioView()
        view.showLinkedIn = { [unowned self] personData in
            self.viewModel.didTapLinkedIn(for: personData)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(peopleCollectionView)
        peopleCollectionView.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: nil,
            trailing: view.trailingAnchor)
        peopleCollectionView.heightAnchor.constraint(equalToConstant: expandedHeight).isActive = true
        if viewModel.people.count > 0 {
            peopleCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
        view.addSubview(bioView)
        bioView.anchor(
            top: peopleCollectionView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20),
            size: CGSize.zero)
        bioView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let index = selectedPersonIndex ?? 0
        let indexPath = IndexPath(row: index, section: 0)
        guard self.viewModel.people.count > 0 else { return }
        peopleCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        refresh()
        DispatchQueue.main.async { [weak self] in
            if indexPath.row == self?.selectedPersonIndex {
                self?.animateSelectPerson()
            } else {
                self?.animateDeselectPerson()
            }
        }

    }

}

extension CompanyPeopleViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PersonCollectionViewCell.reuseIdentifier,
            for: indexPath) as! PersonCollectionViewCell
        let person = viewModel.people[indexPath.row]
        cell.configure(person: person)
        cell.highlightedBorder = indexPath.row == selectedPersonIndex
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return halfWidthSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return halfWidthSize
    }
}

extension CompanyPeopleViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedPersonIndex = viewModel.selectedPersonIndex == indexPath.row ? nil : indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.selectedPersonIndex ==  indexPath.row ? expandedCardSize : standardCardSize
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.selectedPersonIndex = nil
    }
}







