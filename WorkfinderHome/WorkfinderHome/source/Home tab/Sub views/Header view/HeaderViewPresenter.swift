
import WorkfinderCommon

class HeaderViewPresenter {
    
    var name: String {
        let name = UserRepository().loadCandidate().fullName
        let first = name.split(separator: " ")
        return first.isEmpty ? "" : String(first[0])
    }
    
    var rightLabelText: String {
        name.isEmpty ? "Welcome! 🤚" : "Hi Keith! 🤚"
    }
}
