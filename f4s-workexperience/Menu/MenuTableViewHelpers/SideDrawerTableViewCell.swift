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

class SideDrawerTableViewCell: TableViewCell {

    var lineImageView: UIImageView!
    var currentItemImageView: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.lineImageView = UIImageView()
        self.addSubview(self.lineImageView)
        self.currentItemImageView = UIImageView()
        self.addSubview(self.currentItemImageView)
        self.lineImageView.bringSubview(toFront: self)
        self.currentItemImageView.bringSubview(toFront: self)
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
        selectionView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 82)
        selectionView.center = self.center
        self.selectedBackgroundView = selectionView

        self.textLabel?.textColor = UIColor(netHex: Colors.white)
        self.imageView?.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)

        self.lineImageView.backgroundColor = UIColor.clear
    }

    override func updateContentForNewContentSize() {
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.selectedBackgroundView?.frame = CGRect(x: 0, y: 0.5, width: self.bounds.width, height: 82.5)
    }
}
