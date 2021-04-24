//
//  NPSScoreView.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class NPSScoreView: UIView {
    
    private (set) var tiles: [ScoreTile] = []
    
    lazy var text: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Based on your experience with {{Host First Name}} on {{Project Name}}, on a scale of 0 to 10, how likely would you recommend {{Host First Name}} to other candidates?"
        label.textColor = UIColor.darkText
        return label
    }()
    
    lazy private var tilesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: tiles)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [text, tilesStack])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tiles = (0...9).compactMap({ (value) -> ScoreTile? in
            guard let score = Score(rawValue: value+1) else { return nil }
            return ScoreTile(score: score, onTap: onTap)
        })
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
    }
    
    func onTap(score: Score) {
        let tile = tiles[score.rawValue - 1]
        if tile.isSelected {
            tile.isSelected = false
            return
        }
        deselectAll()
        tile.isSelected = true
    }
    
    func deselectAll() {
        tiles.forEach { (tile) in
            tile.isSelected = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum Score: Int, CaseIterable {
    case s0
    case s1
    case s2
    case s3
    case s4
    case s5
    case s6
    case s7
    case s8
    case s9
    case s10
    
    var color: UIColor {
        switch self {
        case .s0: return UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        case .s1: return UIColor(red: 0.817, green: 0.361, blue: 0.361, alpha: 1)
        case .s2: return UIColor(red: 0.896, green: 0.561, blue: 0.455, alpha: 1)
        case .s3: return UIColor(red: 0.929, green: 0.651, blue: 0.395, alpha: 1)
        case .s4: return UIColor(red: 0.913, green: 0.742, blue: 0.304, alpha: 1)
        case .s5: return UIColor(red: 0.917, green: 0.866, blue: 0.413, alpha: 1)
        case .s6: return UIColor(red: 0.873, green: 0.883, blue: 0.39, alpha: 1)
        case .s7: return UIColor(red: 0.836, green: 0.896, blue: 0.47, alpha: 1)
        case .s8: return UIColor(red: 0.699, green: 0.842, blue: 0.396, alpha: 1)
        case .s9: return UIColor(red: 0.614, green: 0.812, blue: 0.459, alpha: 1)
        case .s10: return UIColor(red: 0.467, green: 0.812, blue: 0.46, alpha: 1)
        }
    }
}


class ScoreTile: UIView {
    
    let score: Score
    
    var onTap: ((Score) -> Void)?
    
    var isSelected: Bool = false {
        didSet {
            label.alpha = isSelected ? 1 : 0.7
            let color = isSelected ? UIColor.black :  UIColor.init(white: 0.8, alpha: 1)
            label.textColor = color
            label.layer.borderWidth = isSelected ? 2 : 1
            label.layer.borderColor = color.cgColor
        }
    }
    
    private func applyScore() {
        label.text = String(score.rawValue)
        label.backgroundColor = score.color
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc private func tapped() {
        onTap?(score)
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.heightAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        return label
    }()
    
    init(score: Score, onTap: @escaping (Score) -> Void) {
        self.score = score
        self.onTap = onTap
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        applyScore()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
