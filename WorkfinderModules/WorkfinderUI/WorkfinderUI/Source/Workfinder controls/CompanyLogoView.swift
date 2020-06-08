
import UIKit

public class CompanyLogoView: UIView {
    
    let widthPoints: CGFloat
    
    private lazy var logoView: F4SSelfLoadingImageView = {
        let logoView = F4SSelfLoadingImageView()
        logoView.layer.masksToBounds = true
        logoView.layer.borderColor = UIColor.init(netHex: 0xE5E5E5).cgColor
        logoView.layer.borderWidth = 1
        logoView.layer.cornerRadius = 10
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        return logoView
    }()
    
    public init(widthPoints: CGFloat = 64) {
        self.widthPoints = widthPoints
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
    
    public func load(
        companyName: String,
        urlString: String?,
        fetcher: ImageFetching = ImageFetcher(),
        completion: (() -> Void)?) {
        let backgroundColor = WorkfinderColors.primaryColor
        let firstCharacter: Character = companyName.first ?? "?"
        let defaultImage: UIImage = UIImage.from(
            size: CGSize(width: widthPoints, height: widthPoints),
            string: String(firstCharacter),
            backgroundColor: backgroundColor)
        logoView.load(urlString: urlString,
                      defaultImage: defaultImage,
                      fetcher: fetcher,
                      completion: completion)
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


