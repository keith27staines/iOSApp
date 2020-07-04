
public class KSClusterManager {
    public let bounds: KSRect
    public var pinsQuadTree: KSQuadTree
    public var clustersQuadTree: KSQuadTree
    public private (set) var pins: [KSPin] = []
    
    public init(bounds: KSRect) {
        self.bounds = bounds
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
    }
    
    public func insert(_ pins: [KSPin]) {
        for pin in pins {
            try? insertPin(pin)
        }
    }
    
    func insertPin(_ pin: KSPin) throws {
        let item = KSQuadTreeItem(point: pin.point, object: pin)
        try pinsQuadTree.insert(item: item)
        pins.append(pin)
    }
    
    public func clear() {
        pins = []
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
    }
    
    public func getClusters() -> [KSCluster] {
        clustersQuadTree.retrieveAll().compactMap { ($0.object as? KSCluster) }
    }
    
    public func rebuildClusters(catchementSize: KSSize, in rect: KSRect) {
        clustersQuadTree = KSQuadTree(bounds: bounds)
        let pins = pinsQuadTree.retrieveWithinRect(rect).compactMap { (item) -> KSPin? in
            item.object as? KSPin
        }
        for pin in pins {
            let catchement = KSRect(center: pin.point, size: catchementSize)
            addPinToNearestClusterInCatchementRect(pin: pin, rect: catchement)
        }
    }
    
    func addPinToNearestClusterInCatchementRect(pin: KSPin, rect: KSRect) {
        let nearby = clustersQuadTree.retrieveWithinRect(rect)
        guard let nearestCluster = findNearest(to: pin, from: nearby)?.object as? KSCluster
            else {
                let newCluster = KSCluster(id: "", centerPin: pin)
                let item = KSQuadTreeItem(point: newCluster.centerPin.point, object: newCluster)
                try? clustersQuadTree.insert(item: item)
                return
        }
        nearestCluster.addPin(pin)
    }
    
    func findNearest<A:XYLocatable, B:XYLocatable>(to object: A, from others: [B] ) -> B? {
        var leastDistance = Float.greatestFiniteMagnitude
        var closest: B?
        for other in others {
            let aDistance = object.distance2From(other)
            if aDistance < leastDistance {
                leastDistance = aDistance
                closest = other
            }
        }
        return closest
    }
}
