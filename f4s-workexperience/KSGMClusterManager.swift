
import GoogleMaps

public class KSGMClusterManager: NSObject {
    
    public let bounds = KSRect(x: -180, y: -90, width: 360, height: 90)
    public var pinsQuadTree: KSQuadTree
    public var clustersQuadTree: KSQuadTree
    public private (set) var pins: [KSPin] = []
    weak var mapDelegate: GMSMapViewDelegate?
    var clusterTapped: ((KSCluster) -> Void)?
    weak var mapView: GMSMapView?
    
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
    
    public func insert(_ pins: [KSPin]) {
        for pin in pins {
            try? insertPin(pin)
        }
    }
    
    func insertPin(_ pin: KSPin) throws {
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
    
    public func rebuildClusters(catchementSize: KSSize, in rect: KSRect) {
        clustersQuadTree = KSQuadTree(bounds: bounds)
        let pins = pinsQuadTree.retrieveWithinRect(rect).compactMap { (item) -> KSPin? in
            item as? KSPin
        }
        for pin in pins {
            let catchement = KSRect(center: pin.point, size: catchementSize)
            addPinToNearestClusterInCatchementRect(pin: pin, rect: catchement)
        }
    }
    
    func addPinToNearestClusterInCatchementRect(pin: KSPin, rect: KSRect) {
        guard
            let nearby = clustersQuadTree.retrieveWithinRect(rect) as? [KSCluster],
            let nearestCluster = findNearest(to: pin, from: nearby)
            else {
                let newCluster = KSCluster(id: "", centerPin: pin)
                try? clustersQuadTree.insert(item: newCluster)
                return
        }
        nearestCluster.addPin(pin)
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
