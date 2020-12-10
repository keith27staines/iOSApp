
import UIKit
import WorkfinderUI

class TypeAheadCell: UITableViewCell {
    
    static let reuseIdentifier = "TypeAheadCell"
 
    var defaultImage = UIImage()
    lazy var iconLoader: ImageLoader = {
        ImageLoader()
    }()
    
    func updateFrom(_ typeAhead: TypeAheadItem) {
        let downloadFromUrlString = typeAhead.iconUrlString ?? ""
        textLabel?.text = typeAhead.title
        detailTextLabel?.text = typeAhead.subtitle
        iconLoader.load(urlString: downloadFromUrlString, defaultImage: defaultImage) {
            [weak self] (downloadedFromUrlString, image) in
            guard let self = self, downloadFromUrlString == downloadedFromUrlString else { return }
            self.imageView?.image = image
        }
    }
}

class SafeSelfLoadingImageView: UIImageView {

    let imageLoader = ImageLoader()

    func load(urlString: String, defaultImage: UIImage) {
        imageLoader.load(urlString: urlString, defaultImage: defaultImage) { (downloadedFromUrl, image) in
            guard urlString == downloadedFromUrl else { return }
            self.image = image
        }
    }
}
