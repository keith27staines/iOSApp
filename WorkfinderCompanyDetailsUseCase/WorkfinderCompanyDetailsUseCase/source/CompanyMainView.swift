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
    func companyMainView(_ view: CompanyMainView, didSelectPage: CompanyViewModel.PageIndex?)
    func companyMainViewDidTapApply(_ view: CompanyMainView)
    func companyMainViewDidTapDone(_ view: CompanyMainView)
}

class CompanyMainView: UIView {
    
    private weak var delegate: CompanyMainViewDelegate?
    weak var log: F4SAnalyticsAndDebugging?
    var companyViewModel: CompanyViewModel
    var appSettings: AppSettingProvider
    
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
        toolbarView.heartAppearance(hearted: companyViewModel.isFavourited)
        headerView.refresh()
    }
    
    lazy var headerView: CompanyHeaderView = {
        let view = CompanyHeaderView(delegate: self, companyViewModel: companyViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var toolbarView: CompanyToolbar = {
        let toolbar = CompanyToolbar(toolbarDelegate: self)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl: UISegmentedControl
        switch self.appSettings.currentValue(key: AppSettingKey.showHostsEnabled) {
        case "false":
            segmentedControl = UISegmentedControl(items: ["Company","Data"])
        case "true":
            segmentedControl = UISegmentedControl(items: ["Company","Data", "People"])
        default:
            segmentedControl = UISegmentedControl(items: ["Company","Data"])
        }
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(handleSegmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    func configureViews() {
        addSubview(segmentedControl)
        addSubview(headerView)
        addSubview(toolbarView)
        headerView.anchor(top: layoutMarginsGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 110))
        segmentedControl.anchor(top: headerView.bottomAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: nil, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        toolbarView.anchor(top: nil, leading: leadingAnchor, bottom: layoutMarginsGuide.bottomAnchor, trailing: trailingAnchor)
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
        mapTopConstraint = mapView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
        mapBottomConstraint = mapView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: 0)
        mapTopConstraint?.isActive = true
        mapBottomConstraint?.isActive = true
        mapOffsetConstant = 1000
    }
    
    func addPageControllerView(view: UIView) {
        addSubview(view)
        view.anchor(top: segmentedControl.bottomAnchor, leading: layoutMarginsGuide.leadingAnchor, bottom: toolbarView.topAnchor, trailing: layoutMarginsGuide.trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0))
        self.sendSubviewToBack(view)
    }
    
    @objc func handleSegmentChanged(sender: UISegmentedControl) {
        guard let page = CompanyViewModel.PageIndex(rawValue: sender.selectedSegmentIndex) else { return }
        switch page {
        case .summary:
            log?.track(event: .companyDetailsCompanyTabTap, properties: nil)
        case .data:
            log?.track(event: .companyDetailsDataTabTap, properties: nil)
        case .people:
            log?.track(event: .companyDetailsPeopleTabTap, properties: nil)
        }
        delegate?.companyMainView(self, didSelectPage: page)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompanyMainView : CompanyToolbarDelegate {
    func companyToolbar(_: CompanyToolbar, requestedAction: CompanyToolbar.ActionType) {
        delegate?.companyToolbar(toolbarView, requestedAction: requestedAction)
    }
}
extension CompanyMainView : CompanyHeaderViewDelegate {
    func didTapApply() {
        log?.track(event: .companyDetailsApplyTap, properties: nil)
        delegate?.companyMainViewDidTapApply(self)
    }
    
    func didTapDone() {
        log?.track(event: .companyDetailsCloseTap, properties: nil)
        delegate?.companyMainViewDidTapDone(self)
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
