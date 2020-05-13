
import UIKit

public class CompanyLogoView: UIView {
    
    private lazy var logoView: F4SSelfLoadingImageView = {
        let logoView = F4SSelfLoadingImageView()
        logoView.layer.cornerRadius = 8
        logoView.layer.borderWidth = 2
        logoView.layer.masksToBounds = true
        logoView.layer.borderColor = UIColor.lightGray.cgColor
        logoView.contentMode = .scaleAspectFit
        logoView.layer.shadowRadius = 5
        logoView.layer.shadowColor = UIColor.black.cgColor
        logoView.translatesAutoresizingMaskIntoConstraints = false
        return logoView
    }()
    
    public init(widthPoints: CGFloat = 64) {
        super.init(frame: CGRect.zero)
        addSubview(logoView)
        logoView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        logoView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        logoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: widthPoints).isActive = true
        logoView.defaultImage = UIImage(named: "DefaultLogo")
        logoView.contentMode = .scaleAspectFit
    }
    
    public func load(urlString: String?,
              defaultImage: UIImage?,
              fetcher: ImageFetching?,
              completion: (() -> Void)?) {
        logoView.load(urlString: urlString,
                      defaultImage: defaultImage,
                      fetcher: fetcher,
                      completion: completion)
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


