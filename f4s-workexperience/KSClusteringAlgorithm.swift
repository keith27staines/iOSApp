
import Foundation
import KSGeometry
import KSQuadTree

class KSClusteringAlgorithm {
    
    let rebuildQueue = DispatchQueue(label: "rebuildClusters", qos: .userInteractive)
    var rebuildWorkItem: DispatchWorkItem?
    private var _nextClusterId: Int = 0
    
    private func nextClusterId() -> Int {
        _nextClusterId += 1
        return _nextClusterId
    }
    
    init() {

    }
    
    func requestRebuildClusters(
        bounds: KSRect,
        pins: Set<KSPin>,
        catchementSize: KSSize,
        pinsQuadTree: KSQuadTree,
        completion: @escaping (KSQuadTree, [KSCluster]) -> Void) {
        rebuildWorkItem?.cancel()
        let workItem = makeRebuildClustersWorkItem(
            bounds: bounds,
            pins: pins,
            catchementSize: catchementSize,
            pinQuadTree: pinsQuadTree) {
                clustersQuadTree, clusters in
                completion(clustersQuadTree, clusters)
        }
        rebuildWorkItem = workItem
        rebuildQueue.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }
    
    private func makeRebuildClustersWorkItem(
        bounds: KSRect,
        pins: Set<KSPin>,
        catchementSize: KSSize,
        pinQuadTree: KSQuadTree,
        completion: @escaping (KSQuadTree, [KSCluster]) -> Void) -> DispatchWorkItem {
        
        return DispatchWorkItem(qos: .userInteractive) { [weak self] in
            guard let self = self else { return }
            let clustersQuadTree = KSQuadTree(bounds: bounds)
            var unclusteredPins = pins
            var clusters = [KSCluster]()
            for pin in pins {
                guard unclusteredPins.contains(pin) else { continue }
                let cluster = KSCluster(id: self.nextClusterId(), centerPin: pin)
                do {
                    try clustersQuadTree.insert(item: cluster)
                    clusters.append(cluster)
                    unclusteredPins.remove(pin)
                    let catchementRect = KSRect(center: pin.point, size: catchementSize)
                    let nearyItems = pinQuadTree.retrieveWithinRect(catchementRect)
                    for item in nearyItems {
                        guard
                            let nearbyPin = item as? KSPin,
                            unclusteredPins.contains(nearbyPin) else { continue}
                        cluster.addPin(nearbyPin)
                        unclusteredPins.remove(nearbyPin)
                    }
                } catch {
                    continue
                }
            }
            DispatchQueue.main.async {
                completion(clustersQuadTree, clusters)
            }
        }
    }
}
