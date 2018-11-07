//
//  DocumentTypeViewController.swift
//  DocumentCapture
//
//  Created by Keith Dev on 03/09/2018.
//  Copyright © 2018 Founders4Schools. All rights reserved.
//

import UIKit

class F4SDCDocumentTypeViewController: UIViewController {
    
    var selectedIndex: Int? = nil
    
    lazy var dropHeightBaseValue: CGFloat = {
        self.labelContainerView.frame.height + 8.0
    }()
    
    var dropHeight: CGFloat = 0.0 {
        didSet {
            self.dropHeightConstraint.constant = self.dropHeight
            UIView.animate(withDuration: 0.25, animations: {
                self.view.superview?.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    var dropHeightConstraint: NSLayoutConstraint!
    var onSelected: ((Int) -> ())?
    
    @IBOutlet weak var labelContainerView: UIView!
    @IBOutlet weak var selectedDocumentTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var labelView: UILabel!
    
    var documentTypes: [F4SUploadableDocumentType] = [F4SUploadableDocumentType.other] {
        didSet {
            let _ = view
            tableView.reloadData()
            selectedIndex = documentTypes.count == 1 ? 0 : nil
            dropDownButton.isHidden = documentTypes.count < 2
            selectedDocumentTypeLabel.textColor = documentTypes.count < 2 ?  UIColor.lightGray : UIColor.black
            labelContainerView.layer.borderColor = selectedDocumentTypeLabel.textColor.cgColor
            labelView.text = selectedIndex == nil ? "" : documentTypes[selectedIndex!].name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        view.layoutIfNeeded()
        setupViews()
    }
    
    func setupViews() {
        setupLabelContainerView()
        setupTableView()
    }
    func setupTableView() {
        dropHeightConstraint.constant = dropHeightBaseValue
        dropHeight = dropHeightBaseValue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.red
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.cornerRadius = 8
    }
    func setupLabelContainerView() {
        labelContainerView.layer.borderColor = UIColor.lightGray.cgColor
        labelContainerView.layer.borderWidth = 0.5
        labelContainerView.layer.cornerRadius = 8.0
        labelView.isUserInteractionEnabled = true
        labelView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dropDownButtonTapped)))
    }
    @IBAction func dropDownButtonTapped(_ sender: Any) {
        guard !dropDownButton.isHidden else { return }
        dropHeight = dropHeightBaseValue + tableView.contentSize.height
    }
}

extension F4SDCDocumentTypeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = documentTypes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        dropHeight = dropHeightBaseValue
        labelView.text = documentTypes[indexPath.row].name
        onSelected?(selectedIndex!)
    }
}
