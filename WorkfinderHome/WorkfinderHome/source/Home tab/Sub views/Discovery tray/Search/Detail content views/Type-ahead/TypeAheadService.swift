
import WorkfinderServices

protocol TypeAheadServiceProtocol {
    func fetch(search: String, queryString: String, completion: @escaping ([String]) -> Void)
}

class TypeAheadService: WorkfinderService, TypeAheadServiceProtocol {
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "TypeAheadQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func fetch(search: String, queryString: String, completion: @escaping ([String]) -> Void) {
        queue.cancelAllOperations()
        let operation = TypeAheadOperation(search: search)
        operation.completionBlock = {
            guard !operation.isCancelled else { return }
            completion(operation.results)
        }
        queue.addOperation(operation)
    }
}

class TypeAheadOperation: Operation {
    var results = [String]()
    let search: String
    let chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    override func main() {
        var results = [String]()
        let resultCount = 2*max(10 - search.count, 0)
        for _ in  0 ..< resultCount {
            guard !isCancelled else { break }
            var result: String = search
            let addCount = (0..<10).randomElement() ?? 0
            for _ in 0 ..< addCount {
                guard !isCancelled else { break }
                result.append(String(chars.randomElement() ?? Character("")))
            }
            results.append(result)
            if !isCancelled { Thread.sleep(forTimeInterval: 0.02) }
        }
        guard !isCancelled else { return }
        self.results = results
    }
    
    init(search: String) {
        self.search = search
        super.init()
    }
}
