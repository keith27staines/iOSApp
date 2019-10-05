// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import WorkfinderCommon
import WorkfinderUI

class SideDrawerLogosTableviewCell: SideDrawerTableViewCell {
    
    lazy var imageStack: UIStackView = {
        let imageStack = UIStackView()
        imageStack.axis = .horizontal
        imageStack.spacing = 40
        imageStack.distribution = .fillEqually
        imageStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageStack)
        imageStack.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        imageStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        imageStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        imageStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        return imageStack
    }()
    
    private var imageViews = [UIImageView]()
    
    func setLogos(_ images: [UIImage?]) {
        imageViews.forEach { (imageView) in
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
        images.forEach { (image) in
            if let image = image {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageViews.append(imageView)
                imageStack.addArrangedSubview(imageView)
            }
        }
    }
}

class SideDrawerTableViewHeaderCell: SideDrawerTableViewCell {
    override func commonSetup() {
        super.commonSetup()
    }
    
}

class SideDrawerTableViewCell: TableViewCell {

    lazy var lineImageView: UIImageView = {
        let lineImageView = UIImageView()
        lineImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineImageView)
        lineImageView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        let textLabelLeft = self.leftAnchor // textLabel?.leftAnchor ?? self.leftAnchor
        let textLabelRight = self.rightAnchor // textLabel?.rightAnchor ?? self.rightAnchor
        let textLabelWidth = self.widthAnchor
        lineImageView.leftAnchor.constraint(equalTo: textLabelLeft, constant: 8).isActive = true
        lineImageView.widthAnchor.constraint(equalTo: textLabelWidth, constant: -40).isActive = true
        lineImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        return lineImageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.lineImageView.bringSubviewToFront(self)
        self.commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }

    func commonSetup() {
        self.backgroundColor = UIColor.clear
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor(netHex: Colors.waterBlue)
        self.selectedBackgroundView = selectionView
        self.textLabel?.textColor = RGBA.white.uiColor
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        self.imageView?.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        var color = RGBA.white
        color.alpha = 0.5
        self.lineImageView.backgroundColor = color.uiColor
    }

}
