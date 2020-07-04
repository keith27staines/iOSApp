
public struct KSSize: Hashable, Equatable {
    public static let zero = KSSize(width: 0, height: 0)
    public var width: Float
    public var height: Float
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
    
    public func scaled(by f: Float) -> KSSize {
        return KSSize(width: width * f, height: height * f)
    }
}
