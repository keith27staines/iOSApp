

class FiltersModel {
    let projectTypesService: ProjectTypesServiceProtocol
    let employmentTypesService: EmploymentTypesServiceProtocol
    let skillTypeService: SkillAcquiredTypesServiceProtocol
    
    var filterCollections = [FilterCollection]()
    let collectionsOrdering: [FilterCollectionType] = [
        .jobType,
        .projectType,
        .skills,
        .salary
    ]
    
    func index(type: FilterCollectionType) -> Int {
        collectionsOrdering.firstIndex(of: type) ?? -1
    }
    
    func clear() {
        filterCollections.forEach { (collection) in collection.clear() }
    }
    
    var count: Int {
        filterCollections.reduce(0) { (count, collection) -> Int in
            return count + collection.count
        }
    }
    
    var queryItems: [URLQueryItem] {
        filterCollections.compactMap { (collection) -> URLQueryItem? in
            return collection.queryItem
        }
    }
    
    func loadModel(completion: @escaping (Error?) -> Void) {
        projectTypesService.fetch { [weak self] (result) in
            self?.loadCollection(type: .projectType, result: result, sorted: true, completion: completion)
        }
        employmentTypesService.fetch { [weak self] (result) in
            self?.loadCollection(type: .jobType, result: result, sorted: false, completion: completion)
        }
        skillTypeService.fetch { [weak self] (result) in
            self?.loadCollection(type: .skills, result: result, sorted: true, completion: completion)
        }
    }
    
    func loadCollection(
        type: FilterCollectionType,
        result: Result<[String], Error>,
        sorted: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        switch result {
        case .success(let types):
            let orderedTypes = sorted ? types.sorted() : types
            let index = self.index(type: type)
            self.filterCollections[index].addFilters(with: orderedTypes)
        case .failure(let error):
            completion(error)
        }
    }

    init(
        projectTypesService: ProjectTypesServiceProtocol,
        employmentTypesService: EmploymentTypesServiceProtocol,
        skillTypeService: SkillAcquiredTypesServiceProtocol
    ) {
        self.projectTypesService = projectTypesService
        self.employmentTypesService = employmentTypesService
        self.skillTypeService = skillTypeService
        collectionsOrdering.forEach { (type) in
            filterCollections.append(FilterCollection(type: type))
        }
    }
}
