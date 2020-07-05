
public struct KSPin: KSQuadTreeItem, Equatable, Hashable {
    
    public var object: Any?
    public let id: Int
    public let point: KSPoint
    public var x: Double { point.x }
    public var y: Double { point.y }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: KSPin, rhs: KSPin) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(id: Int, point: KSPoint) {
        self.id = id
        self.point = point
    }
    
    public init(id: Int, x: Double, y: Double) {
        self.init(id: id, point: KSPoint(x: x, y: y))
    }
}
