
import Foundation

public protocol SectionSelectorViewDelegate: AnyObject {
    func sectionSelectorView(_ view: SectionSelectorView, didTapOnDescriptor: CompanyTableSectionDescriptor)
}

public class SectionSelectorView: UIStackView {
    let model: CompanyTableSectionsModel
    weak var delegate: SectionSelectorViewDelegate?
    var onColor: UIColor = UIColor.green { didSet { self.updateButtonColors() } }
    var offColor: UIColor = UIColor.lightGray { didSet { self.updateButtonColors() } }
    var buttons = [UIButton]()
    
    public init(model: CompanyTableSectionsModel, delegate: SectionSelectorViewDelegate) {
        self.model = model
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        axis = .horizontal
        spacing = 4
        distribution = .fillEqually
        updateFromModel()
    }
    
    public func updateFromModel() {
        buttons.removeAll()
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for descriptor in model.descriptors {
            let button = makeButton(descriptor: descriptor)
            addArrangedSubview(button)
            buttons.append(button)
        }
    }
    
    func updateButtonColors() {
        for descriptor in model.descriptors {
            buttons[descriptor.index].backgroundColor = descriptor.isHidden ? offColor : onColor
        }
    }
    
    func makeButton(descriptor: CompanyTableSectionDescriptor) -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.layer.cornerRadius = 4
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        configureButtonWithDescriptor(button, descriptor: descriptor)
        return button
    }
    
    func configureButtonWithDescriptor(_ button: UIButton, descriptor: CompanyTableSectionDescriptor) {
        button.setTitle(descriptor.title, for: UIControl.State.normal)
        button.backgroundColor = descriptor.isHidden ? offColor : onColor
        button.tag = descriptor.index
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(sender: UIButton) {
        let descriptor = model[sender.tag]
        delegate?.sectionSelectorView(self, didTapOnDescriptor: descriptor)
    }
    
    public required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
