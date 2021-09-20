//
//  DateSelectorViewController.swift
//  WorkfinderInterviews
//
//  Created by Keith on 16/07/2021.
//

import UIKit
import WorkfinderUI

class DateSelectorViewController: UIViewController {
    
    let presenter: DateSelectorDatasource
    
    lazy var introLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = "Select the best date for your interview"
        label.textAlignment = .center
        label.textColor = WorkfinderColors.gray3
        label.numberOfLines = 0
        return label
    }()
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.tableFooterView = UIView()
        return table
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(introLabel)
        stack.addArrangedSubview(table)
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    func configureViews() {
        view.backgroundColor = UIColor.white
        let guide = view.safeAreaLayoutGuide
        view.addSubview(mainStack)
        mainStack.anchor(top: guide.topAnchor, leading: guide.leadingAnchor, bottom: guide.bottomAnchor, trailing: guide.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    override func viewDidLoad() {
        navigationItem.title = "Interview dates"
        configureViews()
    }
    
    init(presenter: DateSelectorDatasource) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
