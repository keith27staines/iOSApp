
import Foundation

public struct CompanyTableSectionDescriptor {
    public var title: String { return sectionType.rawValue }
    public var index: Int
    public var isHidden: Bool
    public let sectionType: CompanyTableSectionType
    public init(sectionType: CompanyTableSectionType, index: Int, isHidden: Bool) {
        self.sectionType = sectionType
        self.index = index
        self.isHidden = isHidden
    }
}

public enum CompanyTableSectionType: String {
    case companySummary = "Company"
    case companyData = "Data"
    case companyPeople = "People"
}

public class CompanyTableSectionsModel {
    
    public private (set) var descriptors = [CompanyTableSectionDescriptor]()
    
    public func appendDescriptor(sectionType: CompanyTableSectionType,
                                 isHidden: Bool = false) {
        let descriptor = CompanyTableSectionDescriptor(sectionType: sectionType,
                                                       index: descriptors.count,
                                                       isHidden: isHidden)
        descriptors.append(descriptor)
    }
    
    public var count: Int { return descriptors.count }
    
    public subscript(index: Int) -> CompanyTableSectionDescriptor {
        get {
            return descriptors[index]
        }
        
        set(newValue) {
            descriptors[index] = newValue
        }
    }
}


