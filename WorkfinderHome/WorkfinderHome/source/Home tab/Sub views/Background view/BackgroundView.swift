
import UIKit
import WorkfinderUI

class BackgroundView: UIImageView {
    func refresh() {}
    
    let imageHeightScale: CGFloat = 0.3
    
    var upArrowTapped: (()->Void)?
    
    lazy var wfImageView: UIImageView = {
        let image = UIImage(named: "WF_icon")
        let imageView = UIImageView(image: image)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var heading: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = UIFont.systemFont(ofSize: 28,weight: .regular)
        label.textColor = UIColor.white
        label.text = "Welcome to Workfinder"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var subheading: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.font = UIFont.systemFont(ofSize: 18,weight: .light)
        label.textColor = UIColor.white
        label.text = "Let's get work done"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    
    lazy var upArrow: UIImageView = {
        let image = UIImage(named: "up_icon")
        let imageView = UIImageView(image: image)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUpArrowTap)))
        return imageView
    }()
    
    @objc func handleUpArrowTap() { upArrowTapped?() }
    
    lazy var content: UIView = {
        let view = UIView()
        addSubview(view)
        view.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor)
        view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
        isUserInteractionEnabled = true
    }
    
    func configureViews() {
        backgroundColor = WorkfinderColors.primaryColor
        _ = content
        let guide = safeAreaLayoutGuide
        content.addSubview(wfImageView)
        content.addSubview(heading)
        content.addSubview(subheading)
        content.addSubview(upArrow)
        let wfImageHeight = wfImageView.heightAnchor.constraint(equalTo: content.heightAnchor, multiplier: imageHeightScale)
        wfImageHeight.priority = .defaultHigh
        wfImageHeight.isActive = true
        wfImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        let top = wfImageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 32)
        top.priority = .defaultLow
        top.isActive = true
        wfImageView.topAnchor.constraint(greaterThanOrEqualTo: guide.topAnchor, constant: 10).isActive = true
        wfImageView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        heading.anchor(top: wfImageView.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 28, left: 0, bottom: 0, right: 0))
        heading.centerXAnchor.constraint(equalTo: wfImageView.centerXAnchor).isActive = true
        subheading.anchor(top: heading.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        subheading.centerXAnchor.constraint(equalTo: heading.centerXAnchor).isActive = true
       let upArrowTopPadding = upArrow.topAnchor.constraint(equalTo: subheading.bottomAnchor, constant: 56)
        upArrowTopPadding.priority = .defaultLow
        upArrowTopPadding.isActive = true
        upArrow.topAnchor.constraint(greaterThanOrEqualTo: subheading.bottomAnchor, constant: 20).isActive = true
        upArrow.centerXAnchor.constraint(equalTo: subheading.centerXAnchor).isActive = true
        upArrow.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -40).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
