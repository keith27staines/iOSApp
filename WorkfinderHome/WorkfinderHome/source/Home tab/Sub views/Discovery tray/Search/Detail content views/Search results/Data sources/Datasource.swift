
import WorkfinderCommon
import UIKit

class Datasource: NSObject, UITableViewDataSource {
    weak var searchResultsController: SearchResultsController?
    var queryItems = [URLQueryItem]()
    weak var table: UITableView?
    var data = [Any]()
    let tag: Int
    let applicationSource: ApplicationSource
    
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
    
    /// override this method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    init(
        tag: Int,
        table: UITableView,
        searchResultsController: SearchResultsController,
        applicationSource: ApplicationSource) {
        self.tag = tag
        self.table = table
        self.searchResultsController = searchResultsController
        self.applicationSource = applicationSource
        super.init()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
    }
    
}
