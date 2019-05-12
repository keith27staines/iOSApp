import Foundation
import WorkfinderCommon

/// InformationLabelStrings provides methods to obtain the strings describing the fields on the form used to capture user details
struct InformationLabelStrings {
    let infoAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.warmGrey),
        NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.regular),
        ]
    
    let semiBoldInfoAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor(netHex: Colors.warmGrey),
        NSAttributedString.Key.font: UIFont.f4sSystemFont(size: Style.smallTextSize, weight: UIFont.Weight.semibold),
        ]
    
    var dateOfBirthInformationString: NSAttributedString {
        let text1 = NSLocalizedString("When were you born? And ", comment: "")
        let text2 = NSLocalizedString("why do we need to know?", comment: "")
        let string1 = NSAttributedString(string: text1, attributes: infoAttributes)
        let string2 = NSAttributedString(string: text2, attributes: semiBoldInfoAttributes)
        let combinedString = NSMutableAttributedString(attributedString: string1)
        combinedString.append(string2)
        return combinedString
    }
    
    var userEmailInformationString: NSAttributedString {
        let text = NSLocalizedString("Your email", comment: "")
        let string = NSAttributedString(string: text, attributes: infoAttributes)
        return string
    }
    
    var namesInformationString: NSAttributedString {
        let text = NSLocalizedString("Your first and last names", comment: "")
        let string = NSAttributedString(string: text, attributes: infoAttributes)
        return string
    }
    
    var parentEmailInformationString: NSAttributedString {
        let text = NSLocalizedString("Your parent or guardian's email", comment: "")
        let string = NSAttributedString(string: text, attributes: infoAttributes)
        return string
    }
    
    var voucherInformationString: NSAttributedString {
        let text1 = NSLocalizedString("Enter your voucher if you have one", comment: "")
        let text2 = NSLocalizedString("", comment: "")
        let string1 = NSAttributedString(string: text1, attributes: infoAttributes)
        let string2 = NSAttributedString(string: text2, attributes: semiBoldInfoAttributes)
        let combinedString = NSMutableAttributedString(attributedString: string1)
        combinedString.append(string2)
        return combinedString
    }
}
