//
//  ChooseAttributesViewModel.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 28/03/2019.
//  Copyright © 2019 Founders4Schools. All rights reserved.
//

import Foundation
import WorkfinderCommon

public class ChooseAttributesViewModel : NSObject {
    
    weak var coordinator: ChooseAttributesViewControllerCoordinatorProtocol?
    let model: ApplicationLetterTemplateBlanksModelProtocol
    var blank: F4STemplateBlank?
    let matchingBlankFromTemplate: F4STemplateBlank?
    let blankName: TemplateBlankName?
    let choices: [F4SChoice]
    
    public init(model: ApplicationLetterTemplateBlanksModelProtocol, chooseValuesFor blankName: TemplateBlankName) {
        self.model = model
        self.blankName = blankName
        self.matchingBlankFromTemplate = model.templateBlankWithName(blankName.rawValue)
        self.blank = model.populatedBlankWithName(blankName)
        let choices = matchingBlankFromTemplate?.choices ?? [F4SChoice]()
        self.choices = choices.sorted(by: { $0.value < $1.value })
        if blank == nil {
            var blank = matchingBlankFromTemplate
            blank?.choices = []
            self.blank = blank
        }
    }
    
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int {
        guard let _ = blank, let _ = matchingBlankFromTemplate else { return 0 }
        return choices.count
    }
    
    func configure(cell: ChooseAttributesTableViewCell, atIndexPath indexPath: IndexPath) {
        let choice = choices[indexPath.row]
        cell.attributeLabel.text = choice.value.capitalizingFirstLetter()
        cell.checkImageView.image = UIImage(named: "checkImage")
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.white
        cell.checkImageView.isHidden = !isChoiceAlreadySelected(choice)
    }
    
    func choiceForIndexPath(_ indexPath: IndexPath) -> F4SChoice {
        return choices[indexPath.row]
    }
    
    func isChoiceAlreadySelected(_ choice: F4SChoice) -> Bool {
        guard let blank = blank else { return false }
        return blank.choices.contains(where: { $0.uuid == choice.uuid })
    }
    
    func didSelectIndexPath(_ indexPath: IndexPath) -> [IndexPath] {
        guard var blank = blank, let matchingBlankFromTemplate = matchingBlankFromTemplate else { return [] }
        var indexPathsToReload: [IndexPath] = [indexPath]
        let choice = choiceForIndexPath(indexPath)
    
        if isChoiceAlreadySelected(choice) {
            blank.removeChoiceWithUuid(choice.uuid)
        } else {
            if blank.choices.count < matchingBlankFromTemplate.maxChoices {
                blank.choices.append(choice)
            } else if matchingBlankFromTemplate.maxChoices == 1 {
                // special logic for blanks which permit a maximum of one choice: remove the previously selected one and add the new one
                if let lastChoice = blank.choices.last {
                    blank.choices.removeLast()
                    if let attributeIndex = self.matchingBlankFromTemplate?.choices.firstIndex(where: { $0.uuid == lastChoice.uuid }) {
                        indexPathsToReload.append(IndexPath(row: attributeIndex, section: indexPath.section))
                    }
                }
                blank.choices.append(choice)
            }
        }
        try! model.addOrReplacePopulatedBlank(blank)
        self.blank = blank
        return indexPathsToReload
    }
    
    var title: String {
        let unknownField = NSLocalizedString("Unknown field", comment: "")
        guard let templateBlankName = blankName else { return unknownField }
        switch templateBlankName {
        case .personalAttributes: return NSLocalizedString("Personal Attributes", comment: "")
        case .jobRole: return NSLocalizedString("Job Role", comment: "")
        case .employmentSkills: return NSLocalizedString("Employment Skills", comment: "")
        default: return unknownField
        }
    }
}
