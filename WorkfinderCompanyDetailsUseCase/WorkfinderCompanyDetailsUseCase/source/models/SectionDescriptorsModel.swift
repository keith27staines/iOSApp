
import Foundation

public struct SectionDescriptor {
    public var title: String
    public var index: Int
    public var isHidden: Bool
    public init(title: String, index: Int, isHidden: Bool) {
        self.title = title
        self.index = index
        self.isHidden = isHidden
    }
}

public class SectionDescriptorsModel {
    
    public private (set) var descriptors = [SectionDescriptor]()
    
    public func appendDescriptor(title: String, isHidden: Bool = false) {
        let descriptor = SectionDescriptor(title: title, index: descriptors.count, isHidden: isHidden)
        descriptors.append(descriptor)
    }
    
    public var count: Int { return descriptors.count }
    
    public subscript(index: Int) -> SectionDescriptor {
        get {
            return descriptors[index]
        }
        
        set(newValue) {
            descriptors[index] = newValue
        }
    }
}


