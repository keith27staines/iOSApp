
import UIKit
import WorkfinderUI

class FiltersView: UIView {
    
    lazy var topStack: UIStackView = {
        let leftSpacer = UIView()
        let rightSpacer = UIView()
        leftSpacer.widthAnchor.constraint(equalTo: rightSpacer.widthAnchor).isActive = true
        let stack = UIStackView()
        stack.addArrangedSubview(leftSpacer)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(rightSpacer)
        stack.addArrangedSubview(resetButton)
        stack.axis = .horizontal
        return stack
    }()
    
    @objc func reset() {
        
    }
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.tintColor = WorkfinderColors.primaryColor
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filters"
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    func configureViews() {
        addSubview(topStack)
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        topStack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

typealias FilterName = String
typealias FilterCollectionName = String
typealias FilterQueryKey = String

enum FilterCollectionType: CaseIterable {
    case jobType
    case projectType
    case skills
    case salary
    
    var collectionName: FilterCollectionName {
        switch self {
        case .jobType: return "Job type"
        case .projectType: return "Project type"
        case .skills: return "Skills"
        case .salary: return "Salary"
        }
    }
    
    var queryKey: FilterQueryKey {
        switch self {
        case .jobType: return "employment_type"
        case .projectType: return "type"
        case .skills: return "skill"
        case .salary: return "is_paid"
        }
    }
    
}

struct FilterModel {

    var filterCollections = [FilterCollectionType: FilterCollection]()

    init() {
        filterCollections[.jobType] = FilterCollection(type: .jobType)
        filterCollections[.projectType] = FilterCollection(type: .projectType)
        filterCollections[.skills] = FilterCollection(type: .skills)
        filterCollections[.salary] = FilterCollection(type: .salary)
    }
}

struct FilterCollection {
    var name: FilterCollectionName
    var filters = [FilterName:Filter]()
    
    init(type: FilterCollectionType) {
        self.name = type.collectionName
    }
}
struct Filter {
    var name: FilterName
    var value: Bool
}
