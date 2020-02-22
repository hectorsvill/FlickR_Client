//
//  PopAnimator.swift
//  FlickR_Client
//
//  Created by s on 2/20/20.
//  Copyright © 2020 s. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero


    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if let toView = transitionContext.view(forKey: .to) {


            let transitionView = presenting ? toView : transitionContext.view(forKey: .from)!

            let initialFrame = presenting ? transitionView.frame : originFrame
            let finalFrame = presenting ? transitionView.frame : originFrame
            let scaleXFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
            let scaleYFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height

            let scaleTransform = CGAffineTransform(scaleX: scaleXFactor, y: scaleYFactor)

            if presenting {
                transitionView.transform = scaleTransform
                transitionView.center = CGPoint(x: scaleXFactor, y: scaleYFactor)
                transitionView.clipsToBounds = true
            }

            transitionView.layer.masksToBounds = true

            containerView.addSubview(toView)
            containerView.bringSubviewToFront(transitionView)

            toView.transform = CGAffineTransform(scaleX: 0, y: 0)

            UIView.animate(withDuration: duration, animations: {
                transitionView.transform = self.presenting ? .identity : scaleTransform
                transitionView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

            }, completion: { _ in

                transitionContext.completeTransition(true)
            })
        }


    }

}
