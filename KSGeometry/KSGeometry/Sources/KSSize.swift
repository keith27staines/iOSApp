
public struct KSSize: Hashable, Equatable {
    public static let zero = KSSize(width: 0, height: 0)
    public var width: Double
    public var height: Double
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public func scaled(by f: Double) -> KSSize {
        return KSSize(width: width * f, height: height * f)
    }
}
