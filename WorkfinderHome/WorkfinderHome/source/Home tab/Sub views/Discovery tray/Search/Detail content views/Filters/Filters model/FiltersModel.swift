

class FiltersModel {
    let projectTypesService: ProjectTypesServiceProtocol
    var filterCollections = [FilterCollection]()
    let collectionsOrdering: [FilterCollectionType] = [
        .jobType,
        .projectType,
        .skills,
        .salary
    ]
    
    func clear() {
        filterCollections.forEach { (collection) in collection.clear() }
    }
    
    var count: Int {
        filterCollections.reduce(0) { (count, collection) -> Int in
            return count + collection.count
        }
    }
    
    var queryString: String? {
        let params = filterCollections.reduce("") { (result, collection) -> String in
            let queryString = collection.queryString
            guard !queryString.isEmpty else { return result }
            let term = "\(collection.type.queryKey)=\(queryString)"
            guard !result.isEmpty else { return term }
            return result.appending("&\(term)")
        }
        return params.isEmpty ? nil : params
    }
    
    func loadModel(completion: @escaping (Error?) -> Void) {
        projectTypesService.fetch { [weak self] (result) in
            switch result {
            case .success(let projectTypes):
                let orderedType = projectTypes.sorted()
                self?.filterCollections[1].addFilters(with: orderedType)
            case .failure(let error):
                completion(error)
            }
        }
    }

    init(projectTypesService: ProjectTypesServiceProtocol) {
        self.projectTypesService = projectTypesService
        collectionsOrdering.forEach { (type) in
            filterCollections.append(FilterCollection(type: type))
        }
    }
}
