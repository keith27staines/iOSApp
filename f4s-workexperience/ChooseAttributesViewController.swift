//
//  ChooseAttributesViewController.swift
//  f4s-workexperience
//
//  Created by iOS FRB on 11/28/16.
//  Copyright © 2016 Chelsea Apps Factory. All rights reserved.
//

import UIKit

class ChooseAttributesViewController: UIViewController {
    @IBOutlet weak var attributesTableView: UITableView!

    fileprivate let chooseAttributesCellIdentifier = "ChooseAttributesIdentifier"

    var currentTemplate: TemplateEntity?
    var currentAttributeType: ChooseAttributes?
    var currentTemplateBank: TemplateBlank?

    var selectedTemplateChoices: TemplateBlank?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppereance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - adjust appereance()
extension ChooseAttributesViewController {
    func setupAppereance() {
        setupTableView()

        attributesTableView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(netHex: Colors.lightGray)
        self.automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()

        guard let template = self.currentTemplate else {
            return
        }

        for bank in template.blank {
            if bank.name == self.currentAttributeType?.rawValue {
                self.currentTemplateBank = bank
                self.currentTemplateBank?.choices.sort(by: { $0.0.value < $0.1.value })
                self.selectedTemplateChoices = TemplateChoiceDBOperations.sharedInstance.getTemplateChoicesForCurrentUserWithName(name: bank.name)
            }
        }
    }

    func setupNavigationBar() {
        var image = UIImage(named: "backArrow")
        image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action: #selector(popViewController(_:)))

        if let currentAttribute = self.currentAttributeType {
            switch currentAttribute
            {
            case .PersonalAttributes:
                self.title = NSLocalizedString("Personal Attributes", comment: "")
                break
            case .JobRole:
                self.title = NSLocalizedString("Job Role", comment: "")
                break
            default:
                self.title = NSLocalizedString("Employment Skills", comment: "")
                break
            }
        }
    }

    func setupTableView() {
        attributesTableView.delegate = self
        attributesTableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChooseAttributesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let currentTemplate = currentTemplateBank?.choices else {
            return 0
        }
        return currentTemplate.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = attributesTableView.dequeueReusableCell(withIdentifier: chooseAttributesCellIdentifier) as? ChooseAttributesTableViewCell else {
            return UITableViewCell()
        }
        cell.attributeLabel.text = self.currentTemplateBank?.choices[indexPath.row].value.capitalizingFirstLetter()

        cell.checkImageView.isHidden = true
        cell.checkImageView.image = UIImage(named: "checkImage")
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.white

        if let containsChoice = self.selectedTemplateChoices?.choices.contains(where: { $0.uuid == self.currentTemplateBank?.choices[indexPath.row].uuid }),
            containsChoice {
            cell.checkImageView.isHidden = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let templateBank = currentTemplateBank else {
            return
        }

        var indexPathsToReload: [IndexPath] = [indexPath]

        if let containsChoice = self.selectedTemplateChoices?.choices.contains(where: { $0.uuid == self.currentTemplateBank?.choices[indexPath.row].uuid }),
            containsChoice {
            // remove it
            if let attributeIndex = self.selectedTemplateChoices?.choices.index(where: { $0.uuid == self.currentTemplateBank?.choices[indexPath.row].uuid }) {
                self.selectedTemplateChoices?.choices.remove(at: attributeIndex)
            }
        } else {
            // add attribute
            if selectedTemplateChoices?.choices != nil && (selectedTemplateChoices?.choices.count)! < templateBank.maxChoice {
                self.selectedTemplateChoices?.choices.append(templateBank.choices[indexPath.row])
            } else if self.currentAttributeType == ChooseAttributes.JobRole {
                // remove the previous
                // add the current
                if let lastChoice = selectedTemplateChoices?.choices.last {
                    self.selectedTemplateChoices?.choices.removeLast()
                    if let attributeIndex = self.currentTemplateBank?.choices.index(where: { $0.uuid == lastChoice.uuid }) {
                        indexPathsToReload.append(IndexPath(row: attributeIndex, section: indexPath.section))
                    }
                }
                self.selectedTemplateChoices?.choices.append(templateBank.choices[indexPath.row])
            }
        }
        if let selectedTemplateChoices = self.selectedTemplateChoices?.choices {
            var choiceList: [String] = []
            for choice in selectedTemplateChoices {
                choiceList.append(choice.uuid)
            }
            if choiceList.count > 0 {
                TemplateChoiceDBOperations.sharedInstance.saveTemplateChoice(name: templateBank.name, choiceList: choiceList)
            } else {
                /// remove entry from db
                TemplateChoiceDBOperations.sharedInstance.removeTemplateWithName(name: templateBank.name)
            }
            tableView.reloadRows(at: indexPathsToReload, with: .none)
        }
    }
}

// MARK: - user interaction
extension ChooseAttributesViewController {
    func popViewController(_: UIBarButtonItem) {
        if let navCtrl = self.navigationController {
            navCtrl.popViewController(animated: true)
        }
    }
}
