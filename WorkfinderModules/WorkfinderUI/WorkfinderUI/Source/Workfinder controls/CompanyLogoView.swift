
import UIKit

public class CompanyLogoView: SelfloadingImageView {
    
    public func load(companyName: String,
                     urlString: String?,
                     fetcher: ImageFetching = ImageFetcher(),
                     completion: (() -> Void)?) {
        
        logoView.load(urlString: urlString,
                      defaultImage: makeImageFromFirstCharacter(companyName),
                      fetcher: fetcher,
                      completion: completion)
    }
}

public class HostPhotoView: SelfloadingImageView {
    
    public func load(hostName: String,
                     urlString: String?,
                     fetcher: ImageFetching = ImageFetcher(),
                     completion: (() -> Void)?) {
        
        logoView.load(urlString: urlString,
                      defaultImage: makeImageFromFirstCharacter(hostName),
                      fetcher: fetcher,
                      completion: completion)
    }
}

public class SelfloadingImageView: UIView {
    
    let widthPoints: CGFloat
    
    lazy var logoView: F4SSelfLoadingImageView = {
        let logoView = F4SSelfLoadingImageView()
        logoView.layer.masksToBounds = true
        logoView.layer.borderColor = UIColor.init(netHex: 0xE5E5E5).cgColor
        logoView.layer.borderWidth = 1
        logoView.layer.cornerRadius = 10
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        return logoView
    }()
    
    lazy var defaultImage: UIImage = {
        guard
            let name = self.defaultLogoName,
            let image = UIImage(named: name)
            else { return makeImageFromFirstCharacter("?")
        }
        return image
    }()
    
    func makeImageFromFirstCharacter(_ string: String) -> UIImage {
        let backgroundColor = WorkfinderColors.primaryColor
        let firstCharacter: Character = string.first ?? "?"
        let image: UIImage = UIImage.from(
            size: CGSize(width: widthPoints, height: widthPoints),
            string: String(firstCharacter),
            backgroundColor: backgroundColor)
        return image
    }
    
    public func load(
        urlString: String,
        defaultImage: UIImage,
        fetcher: ImageFetching = ImageFetcher(),
        completion: (() -> Void)?) {
        logoView.load(urlString: urlString,
                      defaultImage: defaultImage,
                      fetcher: fetcher,
                      completion: completion)
    }
    
    let defaultLogoName: String?
    
    public init(widthPoints: CGFloat = 64, defaultLogoName: String? = nil) {
        self.widthPoints = widthPoints
        self.defaultLogoName = defaultLogoName
        super.init(frame: CGRect.zero)
        addSubview(logoView)
        logoView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        logoView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        logoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: widthPoints).isActive = true
        logoView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


