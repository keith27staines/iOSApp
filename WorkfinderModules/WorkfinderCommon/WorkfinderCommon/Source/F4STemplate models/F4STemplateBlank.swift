import Foundation

/// Enumerates the different types of a F4STemplateBlank
public enum F4STemplateBlankOptionType : String, Codable {
    case multiselect    // The field can be populated with one or more non-date values
    case select         // the field is populated with a single non-date value
    case date           // The field represents a date
}

/// Predefined names for F4STemplateBlanks
public enum TemplateBlankName: String {
    case personalAttributes = "attributes"
    case jobRole = "role"
    case employmentSkills = "skills"
    case startDate = "start_date"
    case endDate = "end_date"
    case motivation
}

/// F4STemplateBlank instances represent blanks in a template that are to be
/// populated with strings chosen by the user. Each blank contains placeholder
/// text, the F4STemplateBlankOptionType, the maximum number of choices that are
/// allowed to fill the completed blank and an initial value that *appears* to
/// be obsolete
public struct F4STemplateBlank : Codable {
    /// The name of the blank
    public var name: String
    /// The value to be displayed before the user has chosen a value
    public var placeholder: String
    /// The type of blank
    public var optionType: F4STemplateBlankOptionType
    /// The maximum number of choices the user is allowed to select to fill the blank
    public var maxChoices: Int
    /// The array of choices that the user has selected to fill the blank
    public var choices: [F4SChoice]
    /// Obsolete and unused?
    public var initialValue: String?
    
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - name: The name of the blank
    ///   - placeholder: The placeholder text that will be displayed before the user selects a value
    ///   - optionType: The type of blank
    ///   - maxChoices: The maximum number of choices the user can can to fill the blank with
    ///   - choices: An array of choices to fill the blank with
    ///   - initial: Obsolete and unused?
    public init(name: String = "", placeholder: String = "", optionType: F4STemplateBlankOptionType = .select, maxChoices: Int = 0, choices: [F4SChoice] = [], initial: String? = nil) {
        self.name = name
        self.placeholder = placeholder
        self.optionType = optionType
        self.maxChoices = maxChoices
        self.choices = choices
        self.initialValue = initial
    }
    
    /// Removes the choice with the specified uuid if it exists
    public mutating func removeChoiceWithUuid(_ uuid: F4SUUID) {
        guard let index = choices.firstIndex(where: { (choice) -> Bool in choice.uuid == uuid }) else { return }
        choices.remove(at: index)
    }
}

extension F4STemplateBlank {
    private enum CodingKeys : String, CodingKey {
        case name
        case placeholder
        case optionType = "option_type"
        case maxChoices = "max_choice"
        case choices = "option_choices"
        case initialValue = "initial"
    }
}
