
import UIKit
import WorkfinderUI

class HSLoadingOverlay: UIView {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        return activityIndicator
    }()
    
    var caption: String = "" {
        didSet {
            captionLabel.text = caption
            captionLabel.isHidden = caption.isEmpty
        }
    }
    
    lazy var captionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 2
        label.layer.backgroundColor = UIColor.white.cgColor
        label.layer.cornerRadius = 10.0
        label.textAlignment = .center
        label.alpha = 0.9
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        addSubview(captionLabel)
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        captionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20).isActive = true
        captionLabel.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor, constant: 0).isActive = true
        captionLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        captionLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func showOverlay(style: LoadingOverlayStyle) {
        applyStyle(style: style)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        guard let superview = superview else { return }
        guard !(superview is UITableView) else { return }
        fillSuperview()
    }
    
    func applyStyle(style: LoadingOverlayStyle) {
        activityIndicator.color = WorkfinderColors.primaryColor
        switch style {
        case .dark:
            isUserInteractionEnabled = false
            backgroundColor = UIColor.black
            alpha = 0.75
        case .light:
            isUserInteractionEnabled = false
            backgroundColor = UIColor.white
            alpha = 0.75
        case .transparent:
            isUserInteractionEnabled = true
            backgroundColor = UIColor.clear
            alpha = 1
        }
    }

    func hideOverlay() {
        guard superview != nil else { return }
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.alpha = 0
            self?.removeFromSuperview()
        })
    }
}
