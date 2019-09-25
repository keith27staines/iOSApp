public protocol F4SPlacementRepositoryProtocol {
    func save(placement: F4SPlacement)
    func load() -> [F4SPlacement]
}
