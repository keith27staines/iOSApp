
import UIKit

public class CompanyLogoView: SelfloadingImageView {
    
    public var urlString: String? { logoView.fetchedUrlString }
    
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

