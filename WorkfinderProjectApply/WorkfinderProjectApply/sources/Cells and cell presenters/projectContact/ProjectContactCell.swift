
import UIKit
import WorkfinderUI

class ProjectContactCell: PresentableCell {

    var linkedInLink: String?
    
    override func refreshFromPresenter(_ presenter: CellPresenterProtocol) {
        guard let presenter = presenter as? ProjectContactPresenterProtocol else { return }
        name.text = presenter.name
        title.text = presenter.title
        hostInformation.text = presenter.information
        hostInformation.isHidden = hostInformation.text == nil || hostInformation.text?.isEmpty == true
        linkedInLink = presenter.linkedIn
        photo.load(hostName: presenter.name ?? "", urlString: presenter.photo, completion: nil)
    }
    
    lazy var name: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        Style.hostName.text.applyTo(label: label)
        return label
    }()
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        Style.hostRole.text.applyTo(label: label)
        return label
    }()
    
    lazy var hostInformation: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        Style.body.text.applyTo(label: label)
        return label
    }()
    
    lazy var photo: HostPhotoView = {
        let photo = HostPhotoView(widthPoints: 70, defaultLogoName: nil)
        return photo
    }()
    
    lazy var topStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            photo,
            nameAndTitleStack
        ])
        stack.spacing = 20
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var nameAndTitleStack: UIStackView =  {
        let spacer1 = UIView()
        let spacer2 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        spacer2.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [
            spacer1,
            name,
            title,
            spacer2
        ])
        stack.spacing = 4
        spacer1.heightAnchor.constraint(equalTo: spacer2.heightAnchor).isActive = true
        //stack.distribution = .fillEqually
        stack.axis = .vertical
        return stack
    }()
    
    lazy var linkedinStack: UIStackView = {
        let tintColor = UIColor(netHex: 0x027BBB)
        let image = UIImage(named:"ui-linkedin-icon")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let button = UIButton(type: .system)
        button.setTitle("See more on LinkedIn", for: .normal)
        Style.hostLinkedIn.text.applyTo(button: button)
        button.addTarget(self, action: #selector(linkedinTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            button
        ])
        stack.spacing = 20
        stack.alignment = .center
        stack.axis = .horizontal
        return stack
    }()
    
    @objc func linkedinTapped() {
        guard let link = linkedInLink, let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            topStack,
            hostInformation,
            linkedinStack
        ])
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .leading
        return stack
    }()
    
    override func configureViews() {
        super.configureViews()
        contentView.addSubview(mainStack)
        mainStack.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor)
    }

}
