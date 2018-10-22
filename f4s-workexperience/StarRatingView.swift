//
//  StarRatingView.swift
//  StarRating
//
//  Created by Keith Dev on 23/11/2017.
//  Copyright © 2017 F4S. All rights reserved.
//

import UIKit

@IBDesignable
class StarRatingView: UIView {

    /// Name of image used to represent no star
    public var noStar: String = "ratingUnfilledStar"
    /// Name of image used to represent a half-filled star
    public var halfStar: String = "HalfStar"
    /// Name of image used to represent a full star
    public var fullStar: String = "ratingFilledStar"
    
    @IBInspectable public var labelFont: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    
    /// The numerical value to display (0...5)
    @IBInspectable public var rating: Float {
        didSet {
            updateRatingDisplay()
        }
    }
    
    @IBInspectable public var hideValue: Bool = true {
        didSet {
            ratingLabel?.isHidden = hideValue
            layoutIfNeeded()
        }
    }

    private var starRatingStack: UIStackView? = nil
    private var starStack: UIStackView? = nil
    private var starImageViews: [UIImageView]? = [UIImageView]()
    private var ratingLabel: UILabel? = nil
    
    lazy private var ratingValueFormatter: NumberFormatter = {
        return createRatingValueFormatter()
    }()
    
    public override init(frame: CGRect) {
        rating = 3.5
        starRatingStack = UIStackView(arrangedSubviews: starImageViews!)
        super.init(frame: frame)
        addSubviews()
        updateRatingDisplay()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        rating = 3.5
        super.init(coder: aDecoder)
        addSubviews()
        updateRatingDisplay()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 12)
    }
}

// MARK:- Private helper functions to update the display
extension StarRatingView {
    /// Updates the UI to display the current rating
    private func updateRatingDisplay() {
        for i in 0...4 {
            guard let starImageView = starImageViews?[i] else { continue }
            let rIndex = Float(i+1)
            if rating < rIndex - 0.75 {
                starImageView.image = UIImage(named: noStar)
                continue
            }
            if rating >= rIndex - 0.75 && rating < rIndex - 0.25 {
                starImageView.image = UIImage(named: halfStar)
                continue
            }
            starImageView.image = UIImage(named: fullStar)
        }
        ratingLabel?.text = ratingValueFormatter.string(from: NSNumber(value: rating))
    }
}

// MARK:- Private functions to create subviews and underlying data structure
extension StarRatingView {
    
    /// creates the number formatter used to format the rating value
    func createRatingValueFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumIntegerDigits = 1
        return formatter
    }
    
    /// adds the image and label subviews
    private func addSubviews() {
        guard starRatingStack == nil else { return }
        starImageViews = createStarViewsArray()
        starStack = createStarViewStack(stars: starImageViews!)
        ratingLabel = createLabel()
        starRatingStack = createStarRatingStack(starsStack: starStack!, ratingLabel: ratingLabel!)
        self.addSubview(starRatingStack!)
        self.leftAnchor.constraint(equalTo: starRatingStack!.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: starRatingStack!.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: starRatingStack!.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: starRatingStack!.bottomAnchor).isActive = true
    }
    
    private func createStarRatingStack(starsStack: UIStackView, ratingLabel: UILabel) -> UIStackView {
        let stack = UIStackView(frame: CGRect.zero)
        stack.addArrangedSubview(starsStack)
        stack.addArrangedSubview(ratingLabel)
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = "0.0"
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        return label
    }
    
    private func createStarViewStack(stars: [UIImageView]) -> UIStackView {
        let stack = UIStackView(frame: CGRect.zero)
        for star in stars {
            stack.addArrangedSubview(star)
        }
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }
    
    private func createStarViewsArray() -> [UIImageView] {
        var stars = [UIImageView]()
        for _ in 0...4 {
            let starView = createStarView()
            stars.append(starView)
        }
        return stars
    }
    
    private func createStarView() -> UIImageView {
        let starView = UIImageView(frame: CGRect.zero)
        starView.translatesAutoresizingMaskIntoConstraints = false
        addAspectRatioConstraint(view: starView)
        let height = starView.heightAnchor.constraint(equalToConstant: 12)
        height.priority = UILayoutPriority(rawValue: 999)
        height.isActive = true
        return starView
    }
    
    /// Adds a constraint to ensure that the specified view maintains an aspect ratio of 1:1
    private func addAspectRatioConstraint(view: UIView) {
        let aspectRatioConstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: view,
            attribute: NSLayoutConstraint.Attribute.width,
            multiplier: 1.0,
            constant: 0.0)
        aspectRatioConstraint.isActive = true
        view.addConstraint(aspectRatioConstraint)
    }
    
}


















