import Foundation

public class NameLogic {
    public let firstName: String?
    public let otherNames: String?
    public let nameString: String?
    
    public init(nameString: String?) {
        self.nameString = nameString
        guard let nameString = nameString else {
            firstName = nil
            otherNames = nil
            return
        }
        
        let splitNames = nameString.split(separator: " ").compactMap { (substring) -> String? in
            return substring.isEmpty ? nil : String(substring).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalizingFirstLetter()
        }
        firstName = splitNames.first
        let others = splitNames.dropFirst()
        guard !others.isEmpty else {
            otherNames = nil
            return
        }
        otherNames = others.reduce("", { (concatenated, nameComponent) -> String in
            return concatenated + " " + nameComponent
        }).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
