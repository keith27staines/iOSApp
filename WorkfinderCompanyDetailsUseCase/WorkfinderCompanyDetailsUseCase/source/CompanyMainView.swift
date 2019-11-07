//
//  CompanyMainPageView.swift
//  F4SPrototypes
//
//  Created by Keith Dev on 21/01/2019.
//  Copyright © 2019 Keith Staines. All rights reserved.
//

import UIKit
import MapKit
import WorkfinderCommon

protocol CompanyMainViewDelegate : CompanyToolbarDelegate {
    func companyMainViewDidTapApply(_ view: CompanyMainView)
}

class CompanyMainView: UIView {
    
    private weak var delegate: CompanyMainViewDelegate?
    weak var log: F4SAnalyticsAndDebugging?
    var companyViewModel: CompanyViewModel
    var appSettings: AppSettingProvider
    
    let toolbarAlpha: CGFloat = 0.9
    let workfinderGreen = UIColor(red: 57, green: 167, blue: 82)
    
    var hosts: [F4SHost] { return self.companyViewModel.hosts }
    var textModel: TextModel { return self.companyViewModel.textModel }
    
    lazy var hostsSummaryModel: TextModel = {
        return TextModel(hosts: self.hosts)
    }()
    
    lazy var mapView: CompanyMapView = {
        let mapView = CompanyMapView(company: companyViewModel.company)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        return mapView
    }()
    
    init(companyViewModel: CompanyViewModel, delegate: CompanyMainViewDelegate, appSettings: AppSettingProvider) {
        self.companyViewModel = companyViewModel
        self.delegate = delegate
        self.appSettings = appSettings
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        configureViews()
        configureMapView()
        refresh()
    }
    
    func refresh() {
        headerView.refresh()
        tableView.reloadData()
        switch companyViewModel.userCanApply {
        case true:
            applyButton.setTitle("Apply", for: .normal)
            applyButton.isEnabled = true
            applyButton.backgroundColor = workfinderGreen
        case false:
            applyButton.setTitle("Already applied", for: .normal)
            applyButton.isEnabled = false
            applyButton.backgroundColor = UIColor.lightGray
        }
        toolbarView.heartAppearance(hearted: companyViewModel.isFavourited)

    }
    
    lazy var headerView: CompanyHeaderView = {
        return CompanyHeaderView(companyViewModel: self.companyViewModel)
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HostCell.self, forCellReuseIdentifier: HostCell.reuseIdentifier)
        tableView.register(NameValueCell.self, forCellReuseIdentifier: NameValueCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
        return tableView
    }()
    
    lazy var sectionSelectorView: SectionSelectorView = {
        let view = SectionSelectorView(model: self.sectionsModel, delegate: self)
        view.onColor = self.workfinderGreen
        return view
    }()
    
    lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor  = self.workfinderGreen
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.setTitle("Apply", for: .normal)
        button.layer.cornerRadius = 8
        button.alpha = 1.0
        button.isOpaque = true
        return button
    }()
    
    lazy var applyButtonTransparentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 1, alpha: self.toolbarAlpha)
        view.addSubview(self.applyButton)
        self.applyButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24), size: CGSize(width: 0, height: 44))
        return view
    }()
    
    
    lazy var toolbarView: CompanyToolbar = {
        let toolbar = CompanyToolbar(toolbarDelegate: self, alpha: self.toolbarAlpha)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    // switch self.appSettings.currentValue(key: AppSettingKey.ab_CompanyDetailsFirstEmphasis)
    lazy var sectionsModel: CompanyTableSectionsModel = {
        let model = CompanyTableSectionsModel()
        let types: [CompanyTableSectionType] = [.companySummary, .companyData, .companyPeople]
        for sectionType in types {
            model.appendDescriptor(sectionType: sectionType, isHidden: false)
        }
        return model
    }()
    
    func configureViews() {
        addSubview(headerView)
        addSubview(sectionSelectorView)
        addSubview(tableView)
        addSubview(toolbarView)
        addSubview(applyButtonTransparentContainer)
        headerView.anchor(top: layoutMarginsGuide.topAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: nil, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 80))
        sectionSelectorView.anchor(top: headerView.bottomAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: nil, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0))
        toolbarView.anchor(top: nil, leading: leadingAnchor, bottom: layoutMarginsGuide.bottomAnchor, trailing: trailingAnchor)
        applyButtonTransparentContainer.anchor(top: nil, leading: toolbarView.leadingAnchor, bottom: toolbarView.topAnchor, trailing: toolbarView.trailingAnchor)
        tableView.anchor(top: sectionSelectorView.bottomAnchor, leading: sectionSelectorView.leadingAnchor, bottom: bottomAnchor, trailing: sectionSelectorView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
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
    
    func addPageControllerView(view: UIView) {
        addSubview(view)
        view.anchor(top: sectionSelectorView.bottomAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: toolbarView.bottomAnchor, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        self.sendSubviewToBack(view)
    }
    
    func didTapApply() {
        log?.track(event: .companyDetailsApplyTap, properties: nil)
        delegate?.companyMainViewDidTapApply(self)
    }
    
    func profileLinkTap(host: F4SHost) {
        companyViewModel.didTapLinkedIn(for: host)
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
            return 0
        case .companyData:
            return companyViewModel.companyDataModel.numberOfRows
        case .companyPeople:
            return hosts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            return UITableViewCell()
        case .companyData:
            let nameValueCell = tableView.dequeueReusableCell(withIdentifier: NameValueCell.reuseIdentifier) as! NameValueCell
            let nameValue = companyViewModel.companyDataModel.nameValueForRow(index)
            nameValueCell.configureWithNameValue(nameValue)
            return nameValueCell
            
        case .companyPeople:
            let host = hosts[index]
            let state = hostsSummaryModel.expandableLabelStates[index]
            let hostCell = tableView.dequeueReusableCell(withIdentifier: HostCell.reuseIdentifier) as! HostCell
            hostCell.configureWithHost(host, summaryState: state) { (host) in
            }
            return hostCell
        }
    }
}

extension CompanyMainView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsModel[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let sectionModel = sectionsModel[indexPath.section]
        switch sectionModel.sectionType {
        case .companySummary:
            break
        case .companyData:
            break
        case .companyPeople:
            let hostCell = cell as! HostCell
            let host = hosts[indexPath.row]
            var summaryState = textModel.expandableLabelStates[indexPath.row]
            summaryState.isExpanded.toggle()
            textModel.expandableLabelStates[indexPath.row] = summaryState
            hostCell.configureWithHost(host, summaryState: summaryState, profileLinkTap: profileLinkTap)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

extension CompanyMainView : CompanyToolbarDelegate {
    func companyToolbar(_: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        delegate?.companyToolbar(toolbarView, requestedAction: requestedAction)
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
        let event: TrackEvent
        let numberOfRows: Int
        switch descriptor.sectionType {
        case .companySummary:
            event = .companyDetailsCompanyTabTap
            numberOfRows = 0
        case .companyData:
            event = .companyDetailsDataTabTap
            numberOfRows = companyViewModel.companyDataModel.numberOfRows
        case .companyPeople:
            event = .companyDetailsPeopleTabTap
            numberOfRows = hosts.count
        }
        if numberOfRows > 0 {
            log?.track(event: event, properties: nil)
            tableView.scrollToRow(at: IndexPath(row: 0, section: descriptor.index), at: .top, animated: true)
        }
    }
}
