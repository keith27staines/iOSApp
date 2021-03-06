//
//  NPSScoreView.swift
//  WorkfinderNPS
//
//  Created by Keith on 23/04/2021.
//

import UIKit
import WorkfinderUI

class NPSScoreView: UIView {
    
    private (set) var score: Score?
    
    private func setScore(_ rawScore: Int?, notify: Bool) {
        deselectAll()
        guard
            let rawScore = rawScore,
            let score = Score(rawValue: rawScore)
        else {
            if notify { onScoreChanged?(nil) }
            return
        }
        let tile = tiles[score.rawValue]
        tile.isSelected = true
        self.score = score
        if notify {
            onScoreChanged?(score)
        }
    }
    
    private (set) var tiles: [ScoreTile] = []
    var onScoreChanged: ((Score?) -> ())?
    
    func configureWith(introText: String?, score: Int?) {
        self.introText.text = introText
        setScore(score, notify: false)
    }
    
    private lazy var introText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = WorkfinderColors.gray2
        return label
    }()
    
    private lazy var tilesWithLabels: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
                tileLabels,
                tilesStack,
            ]
        )
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var tileLabels: UIStackView = {
        let font = UIFont.systemFont(ofSize: 12, weight: .regular)
        let color = WorkfinderColors.gray2
        let left = UILabel()
        left.text = "Not likely at all"
        let right = UILabel()
        right.text = "Very likely"
        left.font = font
        right.font = font
        left.textColor = color
        right.textColor = color
        let space = UIView()
        let stack = UIStackView(arrangedSubviews: [
                left,
                space,
                right
            ]
        )
        stack.axis = .horizontal
        return stack
    }()
    
    private lazy var tilesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: tiles)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [introText, tilesWithLabels])
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.addArrangedSubview(verticalStack)
        stack.addArrangedSubview(Spacer(width: 20, height: 0))
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()
    
    init(onScoreChanged: @escaping (Score?) -> ()) {
        super.init(frame: CGRect.zero)
        tiles = (0...10).compactMap({ (value) -> ScoreTile? in
            guard let score = Score(rawValue: value) else { return nil }
            return ScoreTile(score: score) { [weak self] score in
                self?.setScore(score.rawValue, notify: true)
            }
        })
        addSubview(mainStack)
        mainStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        self.onScoreChanged = onScoreChanged
    }
    
    func deselectAll() {
        score = nil
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
    
    @objc private func tapped() {
        onTap?(score)
    }
    
    var isSelected: Bool = false {
        didSet {
            let color = isSelected ? UIColor.black :  WorkfinderColors.gray6
            label.textColor = color
            label.layer.borderWidth = isSelected ? 2 : 1
            label.layer.borderColor = color.cgColor
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 24)
        label.heightAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        return label
    }()
    
    init(score: Score, onTap: @escaping (Score) -> Void) {
        self.score = score
        self.onTap = onTap
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        label.text = String(score.rawValue)
        label.backgroundColor = score.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
