
import UIKit

struct TextStyle {
    var size: CGFloat
    var weight: UIFont.Weight
    var color: UIColor
    var font: UIFont { UIFont.systemFont(ofSize: size, weight: weight) }
    var attributes: [NSAttributedString.Key: Any] {
        [.font: font, .foregroundColor: color]
    }
    func applyTo(label: UILabel) {
        label.font = font
        label.textColor = color
    }
    func applyTo(button: UIButton) {
        button.titleLabel?.font = font
        button.titleLabel?.textColor = color
    }
}

enum Style {
    case projectHeading
    case projectHeadingEmphasised
    case body
    case bulletTitle
    case sectionHeading
    case skillsSectionHeading
    case skillsCapsule
    case hostName
    case hostRole
    case hostLinkedIn
    
    var text: TextStyle {
        switch self {
        case .projectHeading:
            return TextStyle(
                size: 20,
                weight: .light,
                color: UIColor.init(white: 0, alpha: 1)
            )
        case .projectHeadingEmphasised:
            return TextStyle(
                size: 20,
                weight: .medium,
                color: UIColor.init(white: 0, alpha: 1)
            )
        case .body:
            return TextStyle(
                size: 17,
                weight: .regular,
                color: UIColor.init(white: 101/255, alpha: 1)
            )
        case .bulletTitle:
            return TextStyle(
                size: 17,
                weight: .medium,
                color: UIColor.init(white: 33/255, alpha: 1)
            )
        case .sectionHeading:
            return TextStyle(
                size: 22,
                weight: .light,
                color: UIColor.init(white: 25/255, alpha: 1)
            )
        case .skillsSectionHeading:
            return TextStyle(
                size: 17,
                weight: .medium,
                color: UIColor.init(white: 33/255, alpha: 1)
            )
        case .skillsCapsule:
            return TextStyle(
                size: 15,
                weight: .regular,
                color: UIColor.init(white: 33/255, alpha: 1)
            )
        case .hostName:
            return TextStyle(
                size: 15,
                weight: .regular,
                color: UIColor.init(white: 0/255, alpha: 1)
            )
        case .hostRole:
            return TextStyle(
                size: 15,
                weight: .regular,
                color: UIColor.init(white: 101/255, alpha: 1)
            )
        case .hostLinkedIn:
            return TextStyle(
                size: 12,
                weight: .regular,
                color: UIColor.init(white: 101/255, alpha: 1)
            )
        }
    }
}

