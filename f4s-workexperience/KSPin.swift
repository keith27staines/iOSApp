
public struct KSPin: KSQuadTreeItem, Hashable {
    
    public var object: AnyHashable?
    public let id: String
    public let point: KSPoint
    public var x: Double { point.x }
    public var y: Double { point.y }
    
    public init(id: String, point: KSPoint) {
        self.id = id
        self.point = point
    }
    
    public init(id: String, x: Double, y: Double) {
        self.init(id: id, point: KSPoint(x: x, y: y))
    }
}
