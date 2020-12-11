
import UIKit

class Datasource: NSObject, UITableViewDataSource {
    weak var searchResultsController: SearchResultsController?
    var lastError: Error?
    var queryItems = [URLQueryItem]()
    weak var table: UITableView?
    var data = [Any]()
    let tag: Int
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    /// override this method
    func loadData() {}
    
    /// override this method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    init(tag: Int, table: UITableView, searchResultsController: SearchResultsController) {
        self.tag = tag
        self.table = table
        self.searchResultsController = searchResultsController
        super.init()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
    }
    
}
