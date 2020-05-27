//
//  CompanyMainView.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import MapKit
import WorkfinderCommon
import WorkfinderUI

protocol CompanyMainViewProtocol: class {
    var presenter: CompanyMainViewPresenterProtocol! { get set }
    func refresh()
}

class CompanyMainView: UIView, CompanyMainViewProtocol, CompanyHostsSectionViewProtocol {
    var presenter: CompanyMainViewPresenterProtocol!
    weak var log: F4SAnalyticsAndDebugging?
    
    var headerViewPresenter: CompanyHeaderViewPresenterProtocol {
        return presenter.headerViewPresenter
    }
    var summarySectionPresenter: CompanySummarySectionPresenterProtocol {
        return presenter.summarySectionPresenter
    }
    var dataSectionPresenter: CompanyDataSectionPresenterProtocol {
        return presenter.dataSectionPresenter
    }
    var hostsSectionPresenter: CompanyHostsSectionPresenterProtocol {
        return presenter.hostsSectionPresenter
    }

    let toolbarAlpha: CGFloat = 0.9
    var isShowingMap: Bool = false {
        didSet {
            switch isShowingMap {
            case true:
                animateMapIn()
            case false:
                animateMapOut()
            }
        }
    }
    
    lazy var mapView: CompanyMapView = {
        let mapView = CompanyMapView(
            companyName: self.presenter.companyName,
            companyLatLon: self.presenter.companyLocation)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        return mapView
    }()
    
    init(presenter: CompanyMainViewPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: CGRect.zero)
        presenter.view = self
        backgroundColor = UIColor.white
        configureViews()
        configureMapView()
        refresh()
    }
    
    func refresh() {
        headerView.refresh(from: headerViewPresenter)
        tableView.reloadData()
        applyButton.setTitle("Apply", for: .normal)
        applyButton.isEnabled = presenter.isHostSelected
        applyButton.backgroundColor = presenter.isHostSelected ? WorkfinderColors.primaryColor : UIColor.init(white: 0.9, alpha: 1)
    }
    
    lazy var headerView: CompanyHeaderViewProtocol = {
        let presenter = self.headerViewPresenter
        let headerView = CompanyHeaderView(presenter: presenter)
        return headerView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HostLocationAssociationCell.self, forCellReuseIdentifier: HostLocationAssociationCell.reuseIdentifier)
        tableView.register(NameValueCell.self, forCellReuseIdentifier: NameValueCell.reuseIdentifier)
        tableView.register(CompanySummaryTextCell.self, forCellReuseIdentifier: CompanySummaryTextCell.reuseIdentifier)
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.register(SectionFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionFooter")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    lazy var applyButton: UIButton = {
        let button = WorkfinderPrimaryButton()
        button.setTitle("Apply", for: .normal)
        button.alpha = 1.0
        button.isOpaque = true
        button.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        return button
    }()
    
    lazy var applyButtonTransparentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 1, alpha: self.toolbarAlpha)
        view.addSubview(self.applyButton)
        self.applyButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24))
        return view
    }()
    
    
    lazy var toolbarView: CompanyToolbar = {
        let toolbar = CompanyToolbar(toolbarDelegate: self, alpha: self.toolbarAlpha)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    lazy var sectionsModel: CompanyTableSectionsModel = {
        let model = CompanyTableSectionsModel()
        let sectionsList: [CompanyTableSectionType] = [
            .companySummary,
            .companyData,
            .companyHosts
        ]
        for section in sectionsList {
            model.appendDescriptor(sectionType: section, isHidden: false)
        }
        return model
    }()
    
    func configureViews() {
        let headerView = self.headerView as! UIView
        addSubview(headerView)
        addSubview(tableView)
        addSubview(toolbarView)
        addSubview(applyButtonTransparentContainer)
        headerView.anchor(top: layoutMarginsGuide.topAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: nil, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 80))
        toolbarView.anchor(top: nil, leading: leadingAnchor, bottom: layoutMarginsGuide.bottomAnchor, trailing: trailingAnchor)
        applyButtonTransparentContainer.anchor(top: nil, leading: toolbarView.leadingAnchor, bottom: toolbarView.topAnchor, trailing: toolbarView.trailingAnchor)
        tableView.anchor(top: headerView.bottomAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    var mapOffsetConstant: CGFloat = 2000 {
        didSet {
            mapTopConstraint?.constant = mapOffsetConstant
            mapBottomConstraint?.constant = mapOffsetConstant
            toolbarView.mapAppearance(shown: mapOffsetConstant <= 0)
        }
    }
    
    var mapTopConstraint: NSLayoutConstraint?
    var mapBottomConstraint: NSLayoutConstraint?
    
    func animateMapIn() {
        bringSubviewToFront(toolbarView)
        mapOffsetConstant = 0.0
        mapView.prepareForDisplay()
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 2,
            options: [],
            animations: { [weak self] in
            self?.layoutSubviews()
        }, completion: nil)
    }
    
    func animateMapOut() {
        bringSubviewToFront(toolbarView)
        mapOffsetConstant = frame.height
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [UIView.AnimationOptions.curveEaseIn],
            animations: { [weak self] in
            self?.layoutSubviews()
        })
    }
    
    func configureMapView() {
        addSubview(mapView)
        mapView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        mapTopConstraint = mapView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        mapBottomConstraint = mapView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 0)
        mapTopConstraint?.isActive = true
        mapBottomConstraint?.isActive = true
        mapOffsetConstant = 1000
    }
    
    @objc func didTapApply() {
        presenter.onDidTapApply()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompanyMainView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = sectionsModel[section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.numberOfRows
        case .companyData:
            return dataSectionPresenter.numberOfRows
        case .companyHosts:
            return hostsSectionPresenter.numberOfRows
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowInSection = indexPath.row
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            return summarySectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyData:
            return dataSectionPresenter.cellForRow(rowInSection, in: tableView)
        case .companyHosts:
            return hostsSectionPresenter.cellforRow(rowInSection, in: tableView)
        }
    }
}

extension CompanyMainView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionFooter") as? SectionFooterView else {
            return UIView()
        }
        return footer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as? SectionHeaderView
            else {
                return UIView()
        }
        let sectionTitle = sectionsModel[section].title
        sectionHeader.setSectionTitle(sectionTitle)
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            break
        case .companyData:
            break
        case .companyHosts:
            let hostCell = cell as! HostLocationAssociationCell
            hostsSectionPresenter.onDidTapHostCell(hostCell, atIndexPath: indexPath)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

}

extension CompanyMainView : CompanyToolbarDelegate {
    func companyToolbar(_: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        isShowingMap.toggle()
    }
}

extension CompanyMainView : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView()
        if annotation is F4SCompanyAnnotation {
            view.canShowCallout = true
            view.image = #imageLiteral(resourceName: "markerFavouriteIcon")
            return view
        }
        return nil
    }
}

extension CompanyMainView: SectionSelectorViewDelegate {
    func sectionSelectorView(_ sectionSelectorView: SectionSelectorView, didTapOnDescriptor descriptor: CompanyTableSectionDescriptor) {
        let numberOfRows: Int
        switch descriptor.sectionType {
        case .companySummary: numberOfRows = summarySectionPresenter.numberOfRows
        case .companyData: numberOfRows = dataSectionPresenter.numberOfRows
        case .companyHosts: numberOfRows = hostsSectionPresenter.numberOfRows
        }
        if numberOfRows > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: descriptor.index), at: .top, animated: true)
        }
    }
}

class SectionHeaderView: UITableViewHeaderFooterView {
    let label = UILabel()
    
    func setSectionTitle(_ string: String?) { label.text = string }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        tintColor = UIColor.white
        addSubview(label)
        label.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SectionFooterView: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 12).isActive = true
        self.frame.size.height = 12
        tintColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
