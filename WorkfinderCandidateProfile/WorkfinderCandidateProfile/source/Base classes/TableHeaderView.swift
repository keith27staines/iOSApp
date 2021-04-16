//
//  TableHeaderView.swift
//  WorkfinderCandidateProfile
//
//  Created by Keith Staines on 15/04/2021.
//

import UIKit

class TableHeaderView: UIView {
    
    weak var table: UITableView?
    private var title: String?
    private var showSearchBar: Bool = false
    private let topMargin: CGFloat = 12
    private let bottomMargin: CGFloat = 12
    
    private let searchBarHeight: CGFloat = 70
    
    init(for table: UITableView, title: String?, showSearchBar: Bool) {
        self.title = title
        self.table = table
        self.showSearchBar = showSearchBar
        super.init(frame: .zero)
        addSubview(vStack)
        vStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: topMargin, left: 12, bottom: bottomMargin, right: 12))
        frame.size = CGSize(width: 100, height: height)
    }
    
    var height: CGFloat {
        var height = CGFloat(0)
        if let table = table, let title = title {
            titleLabel.text = title
            height = titleLabel.sizeThatFits(CGSize(width: table.frame.width, height: 1000)).height
        }
        if showSearchBar {
            height += searchbar.frame.height
        }
        return height + topMargin + bottomMargin
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var hStack: UIStackView = {
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        leftSpacer.widthAnchor.constraint(equalToConstant: 12).isActive = true
        rightSpacer.widthAnchor.constraint(equalToConstant: 12).isActive = true
        let hStack = UIStackView(arrangedSubviews: [
            leftSpacer,
            titleLabel,
            rightSpacer
            ]
        )
        hStack.axis = .horizontal
        hStack.frame.size = CGSize(width: 0, height: height + 24)
        return hStack
    }()
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        if let text = title {
            stack.addArrangedSubview(hStack)
        }
        if showSearchBar {
            stack.addArrangedSubview(searchbar)
        }
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.init(white: 0.56, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var searchbar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        return searchBar
    }()

    
    
}
