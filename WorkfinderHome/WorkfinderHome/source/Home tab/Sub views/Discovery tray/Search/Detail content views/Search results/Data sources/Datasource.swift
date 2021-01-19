
import WorkfinderCommon
import UIKit

class Datasource: NSObject, UITableViewDataSource {
    weak var searchResultsController: SearchResultsController?
    var queryItems = [URLQueryItem]()
    weak var table: UITableView?
    var data = [Any]()
    var nextPageUrl: String?
    let pageSize: Int = 40
    var count: Int = 0
    let tag: Int
    let appSource: AppSource
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func handleDataLoadError(_ error: Error, retry: @escaping () -> Void, completion: (Error?) -> Void) {
        data = []
        table?.reloadData()
        guard let wfError = error as? WorkfinderError else { return }
        wfError.retryHandler = retry
        NotificationCenter.default.post(name: .wfHomeScreenErrorNotification, object: error)
        completion(error)
    }
    
    /// override this method
    func loadData(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func loadNextPage() {
        fatalError("override this method")
    }
    
    func loadNextPageIfNearEnd(row: Int) {
        if row == data.count - pageSize / 2 { loadNextPage() }
    }
    
    /// override this method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        appSource: AppSource) {
        self.tag = tag
        self.table = table
        self.searchResultsController = searchResultsController
        self.appSource = appSource
        super.init()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
    }
    
}
