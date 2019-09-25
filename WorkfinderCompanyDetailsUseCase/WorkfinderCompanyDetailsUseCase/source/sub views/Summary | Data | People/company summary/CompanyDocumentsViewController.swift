import UIKit
import WorkfinderCommon
import WorkfinderUI
import WorkfinderAppLogic
import WorkfinderCoordinators

class CompanyDocumentsViewController : UIViewController {
    
    var companyDocumentsView: CompanyDocumentsView? { return view as? CompanyDocumentsView }
    
    let model: F4SCompanyDocumentsModelProtocol
    
    init(documentsModel: F4SCompanyDocumentsModelProtocol) {
        self.model = documentsModel
        super.init(nibName: nil, bundle: nil)
        loadDocuments()
    }
    
    override func loadView() {
        let documentsView = CompanyDocumentsView()
        documentsView.dataSource = self
        documentsView.delegate = self
        view = documentsView
    }
    var loadDocumentsAttempts = 0
    private func loadDocuments() {
        loadDocumentsAttempts += 1
        model.getDocuments(age: 0) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .error(_):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5, execute: {
                    if strongSelf.loadDocumentsAttempts < 3 { strongSelf.loadDocuments() }
                })
            case .success(_):
                DispatchQueue.main.async { [weak self] in
                    self?.companyDocumentsView?.reloadData()
                }
            }
        }
    }
    
    func displayDocument(_ document: F4SCompanyDocument) {
         NavigationCoordinator.openUrl(document.url)
    }
    
    func explainDocumentNotVisible(_ document: F4SCompanyDocument) {
        let alert = UIAlertController(title: "We can't show you this document", message: "Although the company has told us they have this document, Workfinder does not have access to it", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension CompanyDocumentsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.availableDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let document = model.document(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = document?.name
        let documentIsVisible = document?.isViewable ?? false
        cell.imageView?.image = documentIsVisible ? #imageLiteral(resourceName: "company_doc") : #imageLiteral(resourceName: "ui-company-upload-doc-off-icon")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
}

extension CompanyDocumentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = model.document(indexPath)!
        switch document.isViewable {
        case true:
            displayDocument(document)
        case false:
            explainDocumentNotVisible(document)
        }
    }
}

class CompanyDocumentsView: UITableView {
    
    init() {
        super.init(frame: CGRect.zero, style: .plain)
        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableFooterView = UIView()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

