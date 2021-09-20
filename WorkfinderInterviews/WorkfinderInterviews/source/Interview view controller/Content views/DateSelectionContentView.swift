//
//  DateSelectionContentView.swift
//  WorkfinderInterviews
//
//  Created by Keith on 18/09/2021.
//

import UIKit
import WorkfinderUI

class DateSelectionContentView: BaseContentView {

    override func updateFromPresenter() {
        guard let presenter = presenter else { return }
        super.updateFromPresenter()
        hostNoteHeader.text = presenter.hostNoteHeader
        hostNoteBody.text = presenter.hostNoteBody
        table.dataSource = presenter.dateSelectorDatasource
        table.delegate = presenter.dateSelectorDatasource
    }
    
    lazy var hostNoteHeader: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.labelTextBold
        label.applyStyle(style)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var hostNoteBody: UILabel = {
        let label = UILabel()
        let style = WFTextStyle.labelTextRegular
        label.applyStyle(style)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.register(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier)
        table.heightAnchor.constraint(equalToConstant: 3*44 + 2*16).isActive = true
        table.tableFooterView = UIView()
        table.alwaysBounceVertical = false
        table.rowHeight = 44
        return table
    }()
    
    override func configureMainStack() {
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 16))
        mainStack.addArrangedSubview(introText)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 24))
        mainStack.addArrangedSubview(hostNoteHeader)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 8))
        mainStack.addArrangedSubview(hostNoteBody)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 24))
        mainStack.addArrangedSubview(table)
        mainStack.addArrangedSubview(makeVerticalSpaceWithPreferredHeight(300))
        mainStack.addArrangedSubview(primaryButton)
        mainStack.addArrangedSubview(secondaryButton)
        mainStack.addArrangedSubview(makeVerticalSpace(height: 24))
    }
    
    func makeVerticalSpaceWithPreferredHeight(_ height: CGFloat) -> UIView {
        let view = UIView()
        let height = view.heightAnchor.constraint(equalToConstant: height)
        height.priority = .defaultLow
        height.isActive = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }
    
}
