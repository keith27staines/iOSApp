//
//  RecommendationsViewController.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 02/01/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class CompanyCell : UITableViewCell {
    
    var company: Company! {
        didSet {
            self.companyNameLabel.attributedText = NSAttributedString(
                string: company.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])
            
            self.industryLabel.attributedText = NSAttributedString(
                string: company.industry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            self.starRating.rating = Float(company.rating)
            self.starRating.isHidden = (company.rating == 0) ? true : false
            self.logo.image = UIImage(named: "DefaultLogo")
            if !company.logoUrl.isEmpty, let url = NSURL(string: company.logoUrl) {
                F4SImageService.sharedInstance.getImage(url: url, completion: { [weak self]
                    image in
                    if image != nil {
                        self?.logo.image = image!
                    } else {
                        self?.logo.image = UIImage(named: "DefaultLogo")
                    }
                })
            }
        }
    }
    
    lazy var industryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var starRating: StarRatingView = {
        let ratingView = StarRatingView(frame: CGRect.zero)
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        return ratingView
    }()

    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [companyNameLabel,starRating,industryLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = UIStackView.Alignment.leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        addSubview(logo)
        addSubview(stackView)
        logo.leftAnchor.constraint(equalTo: leftAnchor, constant: 4).isActive = true
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        stackView.leftAnchor.constraint(equalTo: logo.rightAnchor, constant: 12).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -4).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RecommendationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBAction func dismissMe(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var emptyRecomendationsListText: String? = nil
    var selectCompany: Company?
    
    var model: RecommendationsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        reloadModel()
        applyStyle()
    }
    
    func applyStyle() {
        styleNavigationController()
    }
    
    func reloadModel() {
        model = RecommendationsModel()
        model.reload() { [weak self] in
            self?.tableView.reloadData()
            self?.configureNoRecomendationsOverlay()
        }
    }
    
    lazy var emptyRecommendationsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        view.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: tableView.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        view.backgroundColor = UIColor.white
        let label = emptyRecommendationsLabel
        view.addSubview(label)
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return view
    }()
    
    lazy var emptyRecommendationsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    func configureNoRecomendationsOverlay() {
        let defaultText = "No recommendations for you yet"
        if !model.recommendationsExist {
            emptyRecommendationsLabel.text = emptyRecomendationsListText ?? defaultText
            emptyRecommendationsView.isHidden = false
        } else {
            emptyRecommendationsLabel.isHidden = true
        }
    }
}

extension RecommendationsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var recommendation = model.recommendationForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CompanyCell
        cell.company = recommendation.company
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var recommendation = model.recommendationForIndexPath(indexPath)
        guard let company = recommendation.company else {
            return
        }
        CustomNavigationHelper.sharedInstance.presentCompanyDetailsPopover(parentCtrl: self, company: company)
    }
}
