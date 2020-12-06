

class FiltersModel {

    var filterCollections = [FilterCollection]()
    
    func clear() {
        filterCollections.forEach { (collection) in collection.clear() }
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

    init() {
        filterCollections.append(FilterCollection(type: .jobType))
        filterCollections.append(FilterCollection(type: .projectType))
        filterCollections.append(FilterCollection(type: .skills))
        filterCollections.append(FilterCollection(type: .salary))
    }
}
