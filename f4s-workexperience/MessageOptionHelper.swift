//
//  MessageOptionHelper.swift
//  f4s-workexperience
//
//  Created by Timea Tivadar on 1/4/17.
//  Copyright © 2017 freshbyte. All rights reserved.
//

import UIKit
import Foundation

class MessageOptionHelper {
    class var sharedInstance: MessageOptionHelper {
        struct Static {
            static let instance: MessageOptionHelper = MessageOptionHelper()
        }
        return Static.instance
    }

    let verticalSpacing: CGFloat = 30
    let horizontalSpacing: CGFloat = 20
    let multipleQuestionAnswerCellHeight: CGFloat = 44

    func getCellSize(options: [MessageOption], index: Int, font: UIFont = UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular)) -> CGSize {
        let screenWidth: CGFloat = UIScreen.main.bounds.width - 40
        let cellWidth: CGFloat = (screenWidth - 5) / 2
        let labelWidth: CGFloat = cellWidth - horizontalSpacing

        if index == options.count || index > options.count {
            return CGSize(width: screenWidth, height: multipleQuestionAnswerCellHeight)
        }
        if options.count % 2 == 1 && index == options.count - 1 {
            // calculate the text height
            // cell should cover the hole screen
            let currentTextSize: CGSize = MessageOptionHelper.sharedInstance.getTextSize(options[index].value, font: font, maxWidth: screenWidth - horizontalSpacing)
            return CGSize(width: screenWidth, height: currentTextSize.height + verticalSpacing > 44 ? currentTextSize.height + verticalSpacing : 44)
        }
        if index % 2 == 0 {
            // calculate the current text size and the next text size
            let currentTextSize: CGSize = MessageOptionHelper.sharedInstance.getTextSize(options[index].value, font: font, maxWidth: labelWidth)
            let nextTextSize: CGSize = MessageOptionHelper.sharedInstance.getTextSize(options[index + 1].value, font: font, maxWidth: labelWidth)

            if currentTextSize.height > nextTextSize.height {
                return CGSize(width: cellWidth, height: currentTextSize.height + verticalSpacing > 44 ? currentTextSize.height + verticalSpacing : 44)
            }
            return CGSize(width: cellWidth, height: nextTextSize.height + verticalSpacing > 44 ? nextTextSize.height + verticalSpacing : 44)
        } else {
            // calculcate the previous text size and the current text size
            let currentTextSize: CGSize = MessageOptionHelper.sharedInstance.getTextSize(options[index].value, font: font, maxWidth: labelWidth)
            let previousTextSize: CGSize = MessageOptionHelper.sharedInstance.getTextSize(options[index - 1].value, font: font, maxWidth: labelWidth)

            if currentTextSize.height > previousTextSize.height {
                return CGSize(width: cellWidth, height: currentTextSize.height + verticalSpacing > 44 ? currentTextSize.height + verticalSpacing : 44)
            }
            return CGSize(width: cellWidth, height: previousTextSize.height + verticalSpacing > 44 ? previousTextSize.height + verticalSpacing : 44)
        }
    }

    func getFooterSize(options: [MessageOption], font _: UIFont = UIFont.f4sSystemFont(size: Style.smallerMediumTextSize, weight: UIFont.Weight.regular)) -> CGSize {
        var footerHeight: CGFloat = 0
        var index: Int = 0
        while index < options.count {
            footerHeight += MessageOptionHelper.sharedInstance.getCellSize(options: options, index: index).height + 5 //spacing between lines
            index += 2
        }
        footerHeight += 5 //bottom spacing
        return CGSize(width: UIScreen.main.bounds.width, height: footerHeight)
    }

    func getTextSize(_ text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let textString = text as NSString

        let attributes = [NSAttributedStringKey.font: font]
        let rect = textString.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return CGSize(width: rect.width, height: round(rect.height))
    }
}
