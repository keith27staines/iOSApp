//
//  F4SPopupMenuView.swift
//  DocumentCapture
//
//  Created by Keith Dev on 03/09/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

protocol F4SDCPopupMenuViewDelegate {
    func popupMenu(_ menu: F4SDCPopupMenuView, didSelectRowAtIndex: Int)
}

class F4SDCPopupMenuView: UIView {

    var context: Any?
    let reuseId = "cell"
    
    var items: [String] = ["Item1", "Item 2", "Item3"] {
        didSet {
            var width: CGFloat = 0.0
            let fontSize = UIFont.systemFontSize
            for item in items {
                width = max(width, item.widthOfString(usingFont: UIFont.systemFont(ofSize: fontSize)))
            }
            tableView.frame.size = CGSize(width: width * 2, height: CGFloat(items.count * 40))
            frame.size = tableView.frame.size
            tableView.reloadData()
        }
    }
    
    var delegate: F4SDCPopupMenuViewDelegate? = nil
    
    override var isHidden: Bool {
        get {
            deselectRow()
            return super.isHidden
        }
        set {
            deselectRow()
            super.isHidden = newValue
        }

    }
    
    func deselectRow() {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.isScrollEnabled = false
        addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.frame = frame
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension F4SDCPopupMenuView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.popupMenu(self, didSelectRowAtIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
