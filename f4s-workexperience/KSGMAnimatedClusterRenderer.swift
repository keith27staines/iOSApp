
import GoogleMaps

public class KSGMAnimatedClusterRenderer : KSClusterRendererProtocol {
    
    let mapView: GMSMapView
    let imageFactory = KSClusterImageFactory()
    var markers = Set<GMSMarker>()
    var renderedClusters = Set<KSCluster>()
    var renderedPins = Set<KSPin>()
    var clusters = [KSCluster]()
    var pinToOldClusterMap: [KSPin: KSCluster] = [:]
    var pinToNewClusterMap: [KSPin: KSCluster] = [:]
    let zIndex = 1
    var previousZoom: Float = 0
    
    public init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    public func clear() {
        clearMarkers(markers)
        clusters = []
        markers = []
        renderedClusters = []
        renderedPins = []
        pinToOldClusterMap = [:]
        pinToNewClusterMap = [:]
    }
    
    public func renderClusters(_ clusters: [KSCluster]) {
        renderedClusters.removeAll()
        let zoom = mapView.camera.zoom
        let zoomIsIncreasing = zoom > previousZoom ? true : false
        previousZoom = zoom
        if zoomIsIncreasing {
            prepareClustersForAnimation(self.clusters, zoomIsIncreasing: zoomIsIncreasing)
        } else {
            prepareClustersForAnimation(clusters, zoomIsIncreasing: zoomIsIncreasing)
        }
        
        self.clusters = clusters
        let existingMarkers = markers
        markers = []
        switch zoomIsIncreasing {
        case true:
            addOrUpdateClustersAnimated(clusters)
            clearMarkers(existingMarkers)
        case false:
            addOrUpdateClusters(clusters)
            clearMarkersAnimated(existingMarkers)
        }
    }
    
    private func prepareClustersForAnimation(_ clusters: [KSCluster], zoomIsIncreasing: Bool) {
        pinToNewClusterMap = [:]
        pinToOldClusterMap = [:]
        for cluster in clusters {
            for pin in cluster.pins {
                switch zoomIsIncreasing {
                case true: pinToOldClusterMap[pin] = cluster
                case false: pinToNewClusterMap[pin] = cluster
                }
            }
        }
    }
    
    public func update() {
        addOrUpdateClusters(clusters)
    }
    
    func clearMarkersAnimated(_ markers: Set<GMSMarker>) {
        let visibleRegion = mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds(region: visibleRegion)
        for marker in markers {
            guard
                visibleBounds.contains(marker.position),
                let cluster = marker.userData as? KSCluster,
                let targetCluster = findFirstCluster(in: pinToNewClusterMap, withPinInCommonWith: cluster)
                else { continue }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            marker.layer.latitude = targetCluster.location.latitude
            marker.layer.longitude = targetCluster.location.longitude
            CATransaction.commit()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.6) { [weak self] in
            guard let self = self else { return }
            self.clearMarkers(markers)
        }
    }
    
    func findFirstCluster(in pinClusterMap: [KSPin: KSCluster], withPinInCommonWith cluster: KSCluster) -> KSCluster? {
        for pin in cluster.pins {
            if let matchingCluster = pinClusterMap[pin] { return matchingCluster }
        }
        return nil
    }
    
    func addOrUpdateClustersAnimated(_ clusters: [KSCluster]) {
        let visibleRegion = mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds(region: visibleRegion)
        for cluster in clusters {
            guard !renderedClusters.contains(cluster) else { continue }
            var shouldShowCluster = visibleBounds.contains(cluster.location)
            if !shouldShowCluster {
                for pin in cluster.pins {
                    guard
                        let oldCluster = pinToOldClusterMap[pin],
                        visibleBounds.contains(oldCluster.location)
                        else {
                            continue
                    }
                    shouldShowCluster = true
                    break
                }
            }
            if shouldShowCluster {
                if let oldCluster = findFirstCluster(in: pinToOldClusterMap, withPinInCommonWith: cluster) {
                    renderClusterAnimated(cluster, fromLocation: oldCluster.location)
                } else {
                    renderCluster(cluster)
                }
            }
        }
    }
    
    func renderClusterAnimated(_ cluster: KSCluster, fromLocation: CLLocationCoordinate2D) {
        let toLocation = cluster.location
        let marker = addMarkerFor(cluster, location: fromLocation)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        marker.layer.latitude = toLocation.latitude
        marker.layer.longitude = toLocation.longitude
        CATransaction.commit()
    }
    
    private func renderCluster(_ cluster: KSCluster) {
        _ = addMarkerFor(cluster, location: cluster.location)
    }
    
    func addMarkerFor(_ cluster: KSCluster, location: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker(position: location)
        marker.userData = cluster
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.icon = imageFactory.clusterImageForCount(cluster.count)
        marker.zIndex = Int32(zIndex)
        marker.map = mapView
        markers.insert(marker)
        renderedClusters.insert(cluster)
        return marker
    }
}
/*
 
 

 
*/

extension KSGMAnimatedClusterRenderer {
    
    func addOrUpdateClusters(_ clusters: [KSCluster]) {
        let visibleRegion = mapView.projection.visibleRegion()
        let visibleBounds = GMSCoordinateBounds(region: visibleRegion)
        for cluster in clusters {
            guard !renderedClusters.contains(cluster) else { continue }
            let location = cluster.location
            let isClusterInBounds = visibleBounds.contains(location)
            if isClusterInBounds {
                renderCluster(cluster)
            }
        }
    }
    
    private func clearMarkers(_ markers: Set<GMSMarker>) {
        markers.forEach { marker in
            marker.userData = nil;
            marker.map = nil;
        }
    }
}
