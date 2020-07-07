
public protocol KSXYLocatable {
    var x: Double { get }
    var y: Double { get }
    func isCoincidentWith(_ other: KSXYLocatable) -> Bool
    func distance2From(_ other: KSXYLocatable) -> Double
}

public extension KSXYLocatable {
    func isCoincidentWith(_ other: KSXYLocatable) -> Bool {
        x == other.x && y == other.y
    }
    func distance2From(_ other: KSXYLocatable) -> Double {
        (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y)
    }
}
