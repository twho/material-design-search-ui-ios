//
//  AnimHelper.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsung Wei on 7/11/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

class AnimHelper {
    // Singleton
    static let shared = AnimHelper()
    public enum ViewOrigin {
        case below
        case above
        case identity
    }
    /**
     Move up the views from specified position to a specified coordinate above its
     original position. Show the views after moving.
     
     - Parameter view:       The view to be applied this moving animation.
     - Parameter duration:   The duration of the animation.
     - Parameter completion: The completion handler.
     - Parameter fromY:      The y coordinate of the views as the starting position. It is set to be equal to the views heights by default.
     - Parameter toY:        The y coordinate of the views as the ending position. It is set to set to be equal to negative views heights by default.
     */
    public func showViewsByMovingUp(_ views: [UIView], duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil,
                                    fromY: CGFloat? = nil, toY: CGFloat? = nil) {
        views.forEach({
            let startingY = fromY == nil ? $0.frame.height : fromY!
            $0.alpha = 0.0
            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + startingY)
        })
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.15,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        views.forEach {
                            let endingY = toY == nil ? -$0.frame.height : toY!
                            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + endingY)
                            $0.alpha = 1.0
                        }
        }, completion: { (finished) in
            // Reset the views to their original position
            views.forEach {
                $0.transform = .identity
            }
            completion?(finished)
        })
    }
    /**
     Move down the views from specified top position to a specified coordinate below its
     original position. Hide the views after moving.
     
     - Parameter view:       The view to be applied this moving animation.
     - Parameter duration:   The duration of the animation.
     - Parameter completion: The completion handler.
     - Parameter fromY:      The y coordinate of the views as the starting position. It is set to 0 by default, which means views remain their original position.
     - Parameter toY:        The y coordinate of the views as the ending position. It is set to be equal to the views heights by default.
     */
    public func hideViewsByMovingDown(_ views: [UIView], duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil,
                                      fromY: CGFloat? = nil, toY: CGFloat? = nil) {
        views.forEach({
            let startingY = fromY == nil ? 0.0 : fromY!
            $0.alpha = 1.0
            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + startingY)
        })
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.15,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        views.forEach {
                            let endingY = toY == nil ? $0.frame.height : toY!
                            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + endingY)
                            $0.alpha = 0.0
                        }
        }, completion: { (finished) in
            // Reset the views to their original position
            views.forEach {
                $0.transform = .identity
            }
            completion?(finished)
        })
    }
    /**
     Move down the views from specified top position to a specified coordinate below its
     original position. Show the views after moving.
     
     - Parameter view:       The view to be applied this moving animation.
     - Parameter duration:   The duration of the animation.
     - Parameter completion: The completion handler.
     - Parameter fromY:      The y coordinate of the views as the starting position. It is set to 0 by default, which means views remain their original position.
     - Parameter toY:        The y coordinate of the views as the ending position. It is set to be equal to the views heights by default.
     */
    public func showViewsByMovingDown(_ views: [UIView], duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil,
                                      fromY: CGFloat? = nil, toY: CGFloat? = nil) {
        views.forEach {
            let startingY = fromY == nil ? -$0.frame.height : fromY!
            $0.alpha = 0.0
            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + startingY)
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.15,
                       options: .curveEaseOut,
                       animations: { () -> Void in
                        views.forEach {
                            let endingY = toY == nil ? $0.frame.height : toY!
                            $0.transform = CGAffineTransform(translationX: $0.transform.tx, y: $0.transform.ty + endingY)
                            $0.alpha = 1.0
                        }
        }, completion: { (finished) in
            // Reset the views to their original position
            views.forEach {
                $0.transform = .identity
            }
            completion?(finished)
        })
    }
}
