
public class KSCluster: KSQuadTreeItem, Hashable, Equatable {
    public var point: KSPoint { centerPin.point }
    public let id: Int
    public let centerPin: KSPin
    public private (set) var pins: Set<KSPin>
    public var x: Double { return centerPin.x }
    public var y: Double { return centerPin.y }
    public var count: Int { return pins.count }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: KSCluster, rhs: KSCluster) -> Bool {
        lhs.id == rhs.id
    }
    
    public func addPin(_ pin: KSPin) {
        pins.insert(pin)
    }
    
    public init(id: Int, centerPin: KSPin) {
        self.id = id
        self.centerPin = centerPin
        self.pins = Set<KSPin>([centerPin])
    }
    
    public func catchementRectangle(size: KSSize) -> KSRect {
        KSRect(center: centerPin.point, size: size)
    }
    
}
