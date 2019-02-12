//
//  CompanyDescriptionViewController.swift
//  F4SPrototypes
//
//  Created by Keith Staines on 21/12/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

class CompanySummaryViewController: CompanySubViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        refresh()
    }
    
    func configureViews() {
        addSubControllers()
        view.addSubview(industryLabel)
        view.addSubview(ratingView)
        view.addSubview(descriptionView)
        industryLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
        ratingView.anchor(top: industryLabel.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 12))
        ratingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionView.anchor(top: ratingView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        documentsView.anchor(top: descriptionView.bottomAnchor, leading: descriptionView.leadingAnchor, bottom: view.bottomAnchor, trailing: descriptionView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0), size: CGSize(width: 0, height: 100))
    }
    
    var documentsView: UIView!
    
    func addSubControllers() {
        let documentsModel = F4SCompanyDocumentsModel(companyUuid: viewModel.company.uuid)
        let vc = CompanyDocumentsViewController(documentsModel: documentsModel)
        documentsView = vc.view
        view.addSubview(documentsView)
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
    
    private var company: CompanyViewData { return viewModel.companyViewData }
    
    override func refresh() {
        ratingView.rating = company.starRating ?? 0
        ratingView.isHidden = company.starRatingIsHidden
        industryLabel.text = company.industry
        industryLabel.isHidden = company.industryIsHidden
        descriptionView.text = company.description
    }
    
    var industryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    var ratingView: StarRatingView = {
        let ratingView = StarRatingView()
        return ratingView
    }()
    
    lazy var descriptionView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        textView.isEditable = false
        textView.text = ""
        return textView
    }()}
