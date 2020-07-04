
public struct KSPoint: XYLocatable, Hashable, Equatable {
    public static let zero = KSPoint(x: 0, y: 0)
    public var x: Float
    public var y: Float
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}
