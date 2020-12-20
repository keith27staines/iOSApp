
import UIKit

class TypeAheadDataSource {
    
    let service: TypeAheadServiceProtocol
    var didUpdateResults: (() -> Void)?
    var error: Error?
    var totalMatches: Int = 0
    let sectionNames = ["projects", "people"] // ["projects", "companies", "people"]
    
    func itemForIndexPath(_ indexPath: IndexPath) -> TypeAheadItem {
        let sectionName = sectionNames[indexPath.section]
        guard let category = categories[sectionName] else { return TypeAheadItem() }
        guard indexPath.row < category.count else { return TypeAheadItem(title: "No matches")}
        return category[indexPath.row]
    }
    
    var result: Result<TypeAheadJson,Error>? {
        didSet {
            guard let result = result else { return }
            switch result {
            case .success(let typeAheadJson):
                self.categories = [
                    "projects": typeAheadJson.projects ?? [],
//                    "companies": typeAheadJson.companies ?? [],
                    "people": typeAheadJson.people ?? []
                ]
                error = nil
                totalMatches = typeAheadJson.count
            case .failure(let error):
                categories = [:]
                self.error = error
                self.totalMatches = 0
            }
            didUpdateResults?()
        }
    }
    
    var categories = [String:[TypeAheadItem]]()
    
    var searchString: String? {
        didSet {
            let queryItem = URLQueryItem(name: "q", value: searchString)
            service.fetch(queryItems: [queryItem]) { [weak self] (result) in
                self?.result = result
            }
        }
    }
    
    func clear() {
        result = nil
    }
    
    func numberOfSections() -> Int {
        return categories.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        max(categories[sectionNameForIndex(section)]?.count ?? 0, 1)
    }
    
    func sectionNameForIndex(_ index: Int) -> String {
        sectionNames[index]
    }
    
    init(typeAheadService: TypeAheadServiceProtocol) {
        self.service = typeAheadService
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingFromFirstAmbersand() -> String {
        let string = self
        let array = self.split(separator: "&")
        if array.count < 2 { return string }
        return String(array[0])
    }
}
