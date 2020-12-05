
import UIKit

class TypeAheadDataSource {
    
    let service: TypeAheadServiceProtocol
    var didUpdateResults: (() -> Void)?
    var results = [String]() {
        didSet {
            didUpdateResults?()
        }
    }
    
    var string: String? {
        didSet {
            guard let string = string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), string.count > 2 else {
                results = []
                return
            }
            service.fetch(search: string, queryString: "") { results in
                DispatchQueue.main.async { [weak self] in
                    self?.results = results
                }
            }
        }
    }
    
    func clear() {
        results = []
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        results.count
    }
    
    init(typeAheadService: TypeAheadServiceProtocol) {
        self.service = typeAheadService
    }
}

