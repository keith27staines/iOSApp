
import UIKit

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
    
    lazy var logoView: F4SSelfLoadingImageView = {
        let logoView = F4SSelfLoadingImageView()
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


