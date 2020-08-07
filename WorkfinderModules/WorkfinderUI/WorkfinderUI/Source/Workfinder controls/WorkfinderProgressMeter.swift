
import UIKit

public class WorkfinderProgressMeter: UIView {
    
    public let radius: CGFloat
    public let trackColor: UIColor
    public let progressColor: UIColor
    public let textColor: UIColor
    public let trackWidth: CGFloat
    public let font: UIFont
    let trackMargin: CGFloat = 3
    
    public var fractionComplete: CGFloat = 0 {
        didSet {
            self.percentageLabel.text = "\(Int(fractionComplete * 100))%"
            self.progressLayer.strokeEnd = fractionComplete
        }
    }
    
    lazy var circularPath = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    
    lazy var trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = trackWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.path = circularPath.cgPath
        return trackLayer
    }()
    
    lazy var progressLayer: CAShapeLayer = {
        let progressLayer = CAShapeLayer()
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = trackWidth - 2 * trackMargin
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.strokeEnd = 0
        progressLayer.path = circularPath.cgPath
        progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        return progressLayer
    }()
    
    lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0%"
        label.textAlignment = .center
        label.font = font
        return label
    }()
    
    public init(
        radius: CGFloat = 93,
        progressColor: UIColor = UIColor.white,
        trackColor: UIColor = WorkfinderColors.primaryColor,
        textColor: UIColor = UIColor.init(white: 33/255, alpha: 1),
        trackWidth: CGFloat = 17,
        font: UIFont = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: .regular)) {
        self.radius = radius
        self.progressColor = progressColor
        self.trackColor = trackColor
        self.trackWidth = trackWidth
        self.textColor = textColor
        self.font = font
        super.init(frame: CGRect.zero)
        configureViews()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: frame.width/2, y: frame.height/2)
        progressLayer.position = center
        trackLayer.position = center
    }
    
    func configureViews() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        addSubview(percentageLabel)
        percentageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percentageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
