//
//  PopupAnimator.swift
//  f4s-workexperience
//
//  Created by Keith Dev on 15/11/2017.
//  Copyright © 2017 Founders4Schools. All rights reserved.
//

import Foundation
import UIKit

class PopupAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var popupAnimatorDidDismiss: ((PopupAnimator) -> Void)? = nil
    
    var duration: Double {
        return self.presenting ? 1.0 : 0.5
    }
    var damping: CGFloat {
        return self.presenting ? 0.6 : 1.0
    }
    
    var originFrame: CGRect = CGRect.zero
    var presenting: Bool = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView: UIView? = transitionContext.view(forKey: .to)
        let finalView: UIView = presenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!
        let initialFrame = presenting ? originFrame : finalView.frame
        let finalFrame = presenting ? finalView.frame : originFrame
        
        let xScaleFactor = presenting
            ? initialFrame.width / finalFrame.width
            : finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting
            ? initialFrame.height / finalFrame.height
            : finalFrame.height / initialFrame.height
        
        let scaleFactor = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            finalView.transform = scaleFactor
            finalView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
        }
        
        if let toView = toView { containerView.addSubview(toView) }
        containerView.bringSubviewToFront(finalView)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: 0.0,
            animations: {
                finalView.transform = self.presenting ? .identity : scaleFactor
                finalView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        },
            completion: { [weak self] didFinish in
                transitionContext.completeTransition(true)
                guard let strongSelf = self else { return }
                if !strongSelf.presenting {
                    strongSelf.popupAnimatorDidDismiss?(strongSelf)
                }
        }
        )
        
    }
}


