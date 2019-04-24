
import UIKit
import WorkfinderCommon
import WorkfinderApplyUseCase

protocol ChooseAttributesViewControllerCoordinatorProtocol : class {
    func chooseAttributesViewControllerDidFinish()
    func chooseAttributesViewControllerDidCancel()
}

class ChooseAttributesViewController: UIViewController {
    
    weak var coordinator: ChooseAttributesViewControllerCoordinatorProtocol?
    
    @IBOutlet weak var attributesTableView: UITableView!
    fileprivate let chooseAttributesCellIdentifier = "ChooseAttributesIdentifier"
    
    var viewModel: ChooseAttributesViewModel! {
        didSet {
            updateFromViewModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppereance()
        updateFromViewModel()
    }
    
    func updateFromViewModel() {
        guard let viewModel = viewModel else { return }
        title = viewModel.title
    }
}

// MARK: - adjust appereance()
extension ChooseAttributesViewController {
    func setupAppereance() {
        setupTableView()
        attributesTableView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(netHex: Colors.lightGray)
        self.automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
    }

    func setupNavigationBar() {
        let image = UIImage(named: "backArrow")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(complete))
    }

    func setupTableView() {
        attributesTableView.delegate = self
        attributesTableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChooseAttributesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = attributesTableView.dequeueReusableCell(withIdentifier: chooseAttributesCellIdentifier) as! ChooseAttributesTableViewCell
        viewModel.configure(cell: cell, atIndexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        _ = viewModel.didSelectIndexPath(indexPath)
        tableView.reloadData()
    }
}

// MARK: - user interaction
extension ChooseAttributesViewController {
    
    @objc func complete() {
        coordinator?.chooseAttributesViewControllerDidFinish()
    }
    
    @objc func cancel(_: UIBarButtonItem) {
        coordinator?.chooseAttributesViewControllerDidCancel()
    }
}
