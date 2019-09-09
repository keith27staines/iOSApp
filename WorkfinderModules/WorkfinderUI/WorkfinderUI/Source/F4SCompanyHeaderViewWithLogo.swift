//
//  WorkfinderPageHeaderView.swift
//  ViewDesign
//
//  Created by Keith Staines on 21/07/2018.
//  Copyright © 2018 Keith Staines. All rights reserved.
//

import UIKit

@IBDesignable
public class F4SCompanyHeaderViewWithLogo : UIView {
    
    @IBInspectable public var fillTop: Bool = true {
        didSet {
            configure()
        }
    }
    
    @IBInspectable public var leftDrop: CGFloat = 0.2 {
        didSet {
            configure()
        }
    }
    
    @IBInspectable public var rightDrop: CGFloat = 1.0 {
        didSet {
            configure()
        }
    }
    
    @IBInspectable var maxIconHeightFraction: CGFloat = 0.5 {
        didSet {
            configure()
        }
    }
    
    public var leftDropHeight: CGFloat {
        return leftDrop * bounds.height
    }
    
    public var rightDropHeight: CGFloat {
        return rightDrop * bounds.height
    }
    
    @IBInspectable public var icon: UIImage? {
        didSet {
            configure()
        }
    }
    
    @IBInspectable public var fillColor: UIColor = UIColor.blue {
        didSet {
            configure()
        }
    }
    
    fileprivate var shapeLayer = CAShapeLayer()
    fileprivate var iconView = F4SRoundIconView(frame: CGRect.zero)
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    var iconViewCenterYConstraint: NSLayoutConstraint!
    var iconHeightConstraint: NSLayoutConstraint!
    
    func setup() {
        layer.addSublayer(shapeLayer)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(iconView)
        iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconViewCenterYConstraint = iconView.centerYAnchor.constraint(equalTo: topAnchor, constant: 0)
        iconViewCenterYConstraint.isActive = true
        iconHeightConstraint = iconView.heightAnchor.constraint(equalToConstant: 0.0)
        iconHeightConstraint.isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
    }
    
    func configure() {
        iconView.icon = icon
        iconView.isHidden = icon == nil
        shapeLayer.fillColor = fillColor.cgColor
    }
    
    public override func layoutSubviews() {
        
        let middleX = max((bounds.origin.x + bounds.size.width)/2.0, 10.0)
        iconViewCenterYConstraint.constant = slopeHeight(at: middleX)
        iconHeightConstraint.constant = iconHeight(x: middleX)
        shapeLayer.frame = bounds
        shapeLayer.path = fillTop ? createPathTop() : createPathBottom()
        super.layoutSubviews()
    }
    
    func createPathTop() -> CGPath {
        let x0 = bounds.origin.x
        let y0 = bounds.origin.y
        let width = bounds.size.width
        let yLeft = y0 + leftDropHeight
        let yRight = y0 + rightDropHeight
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x0, y: y0))
        path.addLine(to: CGPoint(x: x0 + width, y: y0))
        path.addLine(to: CGPoint(x: x0 + width, y: yRight))
        path.addLine(to: CGPoint(x: x0, y: yLeft))
        path.close()
        return path.cgPath
    }
    
    func createPathBottom() -> CGPath {
        let x0 = bounds.origin.x
        let y0 = bounds.origin.y
        let width = bounds.size.width
        let height = bounds.size.height
        let yLeft = y0 + leftDropHeight
        let yRight = y0 + rightDropHeight
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x0, y: y0 + height))
        path.addLine(to: CGPoint(x: x0 + width, y: y0 + height))
        path.addLine(to: CGPoint(x: x0 + width, y: yRight))
        path.addLine(to: CGPoint(x: x0, y: yLeft))
        path.close()
        return path.cgPath
    }
    
    func slopeHeight(at x:CGFloat) -> CGFloat {
        let x0 = bounds.origin.x
        let y0 = bounds.origin.y
        let x1 = max(x0 + bounds.size.width, 10.0)
        let yLeft = y0 + leftDropHeight
        let yRight = y0 + rightDropHeight
        return yLeft + (yRight-yLeft)/(x1-x0) * (x - x0)
    }
    
    func spaceBelowIconCentre(x:CGFloat) -> CGFloat {
        let below = bounds.size.height - slopeHeight(at: x)
        return below
    }
    
    func spaceAboveIconCentre(x:CGFloat) -> CGFloat {
        let above = slopeHeight(at: x)
        return above
    }
    
    func iconHeight(x:CGFloat) -> CGFloat {
        let largestSize = (min(maxIconHeightFraction * bounds.size.height, spaceAboveIconCentre(x:x), spaceBelowIconCentre(x: x)))
        return 2.0 * largestSize
    }
}























