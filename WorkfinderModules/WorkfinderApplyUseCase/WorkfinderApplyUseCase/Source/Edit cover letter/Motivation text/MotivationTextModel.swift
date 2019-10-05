
import Foundation
import WorkfinderCommon

protocol MotivationTextModelDelegate: class {
    func modelDidUpdate(_ model: MotivationTextModel)
}

class MotivationTextModel {
    weak var delegate: MotivationTextModelDelegate?
    private let repo: F4SMotivationRepositoryProtocol
    var option: MotivationTextOption {
        get { return repo.loadMotivationType() }
        set { repo.saveMotivationType(newValue) }
    }
    private var defaultText: String { return repo.loadDefaultMotivation() }
    private var customText: String {
        get { return repo.loadCustomMotivation() }
        set { repo.saveCustomMotivation(newValue) }
    }
    
    var text: String {
        get {
            switch option {
            case .standard: return defaultText
            case .custom: return customText
            }
        }
        set {
            customText = newValue
            self.delegate?.modelDidUpdate(self)
        }
    }
    let maxCharacters = 1000
    var characterCountText: String { return "\(text.count) of \(maxCharacters)" }
    var editingEnabled: Bool {
        return option == .custom ? true : false
    }
    
    init(repo: F4SMotivationRepositoryProtocol) {
        self.repo = repo
    }
    
    var selectedIndex: Int {
        get {
            switch option {
            case .standard: return 0
            case .custom: return 1
            }
        }
        set {
            self.option = newValue == 0 ? .standard : .custom
            self.delegate?.modelDidUpdate(self)
        }
    }
}
