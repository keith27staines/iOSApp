
import GoogleMaps

public class KSGMClusterManager: NSObject {
    
    public let bounds = KSRect(x: -180, y: -90, width: 360, height: 90)
    public var pinsQuadTree: KSQuadTree
    public var clustersQuadTree: KSQuadTree
    public private (set) var pins: [KSPin] = []
    weak var mapDelegate: GMSMapViewDelegate?
    var clusterTapped: ((KSCluster) -> Void)?
    weak var mapView: GMSMapView?
    private var nextPinId: Int = 0
    private var nextClusterId: Int = 0
    
    public init(mapView: GMSMapView,
                mapDelegate: GMSMapViewDelegate,
                clusterTapped: @escaping (KSCluster) -> Void) {
        self.mapView = mapView
        self.mapDelegate = mapDelegate
        self.clusterTapped = clusterTapped
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
        super.init()
        mapView.delegate = self
    }
    
    public func insertObject(x: Double, y: Double, object: Any) {
        nextPinId += 1
        var pin = KSPin(id: nextPinId, point: KSPoint(x: x, y: y))
        pin.object = object
        try? insertPin(pin)
    }
    
    private func insert(_ pins: [KSPin]) {
        for pin in pins {
            try? insertPin(pin)
        }
    }
    
    private func insertPin(_ pin: KSPin) throws {
        try pinsQuadTree.insert(item: pin)
        pins.append(pin)
    }
    
    public func clear() {
        pins = []
        pinsQuadTree = KSQuadTree(bounds: bounds)
        clustersQuadTree = KSQuadTree(bounds: bounds)
    }
    
    public func getClusters() -> [KSCluster] {
        clustersQuadTree.retrieveAll().compactMap { ($0 as? KSCluster) }
    }
    
    public func rebuildClusters(catchementSize: KSSize) {
        let items = pinsQuadTree.retrieveAll()
        clustersQuadTree = KSQuadTree(bounds: bounds)
        var clusteredPins = Set<KSPin>()
        var unclusteredPins = Set<KSPin>(pinsQuadTree.retrieveAll() as? [KSPin] ?? [])
        for item in items {
            guard let pin = item as? KSPin,
                unclusteredPins.contains(pin) else { continue }
            let cluster = KSCluster(id: nextClusterId, centerPin: pin)
            do {
                try clustersQuadTree.insert(item: cluster)
                unclusteredPins.remove(pin)
                clusteredPins.insert(pin)
            } catch {
                continue
            }

        }
    }
    
    func findNearest<A:XYLocatable, B:XYLocatable>(to object: A, from others: [B] ) -> B? {
        var leastDistance = Double.greatestFiniteMagnitude
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

extension KSGMClusterManager: GMSMapViewDelegate {
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard
            let cluster = marker.userData as? KSCluster,
            let clusterTapped = clusterTapped
            else {
            return self.mapDelegate?.mapView?(mapView, didTap: marker) ?? false
        }
        clusterTapped(cluster)
        return false
    }
}
