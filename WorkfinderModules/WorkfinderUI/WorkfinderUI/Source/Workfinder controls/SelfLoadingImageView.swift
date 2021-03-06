
import UIKit

public class ImageLoader: UIImage {
    
    var imageFetcher: ImageFetching = ImageFetcher()
    
    public func load(
        urlString: String,
        defaultImage: UIImage,
        completion: @escaping (String,UIImage) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(urlString,defaultImage)
            return
        }
        imageFetcher.getImage(url: url) { (downloadedImage) in
            DispatchQueue.main.async {
                completion(urlString,downloadedImage ?? defaultImage)
            }
        }
    }
}

extension UIImage {
    public static func makeImageFromFirstCharacter(_ string: String, size: CGSize) -> UIImage {
        let backgroundColor = WorkfinderColors.primaryColor
        let firstCharacter: Character = string.first ?? "?"
        let image: UIImage = UIImage.from(
            size: CGSize(width: size.width, height: size.height),
            string: String(firstCharacter),
            backgroundColor: backgroundColor)
        return image
    }
}

public class SelfloadingImageView: UIView {
    
    let widthPoints: CGFloat
    let padding: CGFloat = 4
    let imageRadius: CGFloat = 12
    var containerRadius: CGFloat { imageRadius + padding}
    
    lazy var logoContainer: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.borderColor = UIColor.init(netHex: 0xE5E5E5).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.containerRadius
        view.addSubview(logoView)
        logoView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        return view
    }()
    
    lazy var logoView: WFSelfLoadingImageView = {
        let logoView = WFSelfLoadingImageView()
        logoView.layer.masksToBounds = true
        logoView.layer.cornerRadius = self.imageRadius
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
        UIImage.makeImageFromFirstCharacter(string, size: CGSize(width: widthPoints, height: widthPoints))
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
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoContainer)
        logoContainer.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        logoContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        logoContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoContainer.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoContainer.widthAnchor.constraint(equalTo: logoContainer.heightAnchor).isActive = true
        logoContainer.widthAnchor.constraint(equalToConstant: widthPoints).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


