
public struct KSPoint: KSXYLocatable, Hashable, Equatable {
    public static let zero = KSPoint(x: 0, y: 0)
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
