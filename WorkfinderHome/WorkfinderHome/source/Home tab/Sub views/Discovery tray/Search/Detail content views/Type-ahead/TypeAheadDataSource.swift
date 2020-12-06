
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
            let search = string.deletingPrefix("?q=").deletingFromFirstAmbersand()
            print("Search string: " + search)
            service.fetch(search: search) { results in
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
