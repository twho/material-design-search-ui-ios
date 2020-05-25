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
    /**
     Move up the views to specified bottom position.
     
     - Parameter views:      The views to be applied this moving animation.
     - Parameter duration:   The duration of the animation.
     - Parameter completion: The completion handler.
     - Parameter show:       The boolean to determine move in or out views. Set true to move in.
     */
    public func moveUpViews(_ views: [UIView], duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil, show: Bool) {
        views.forEach({
            $0.alpha = show ? 0.0 : 1.0
            if show {
                $0.transform = CGAffineTransform(translationX: 0, y: $0.frame.maxY)
            }
        })
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.15,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        views.forEach {
                            $0.transform = show ? .identity : CGAffineTransform(translationX: 0, y: -$0.frame.maxY)
                            $0.alpha = show ? 1.0 : 0.0
                        }
        }, completion: completion)
    }
    /**
     Move down the views from specified top position to its right position.
     
     - Parameter views:      The views to be applied this moving animation.
     - Parameter duration:   The duration of the animation.
     - Parameter completion: The completion handler.
     - Parameter show:       The boolean to determine move in or out views. Set true to move in.
     */
    public func moveDownViews(_ views: [UIView], duration: TimeInterval = 0.5, completion: ((Bool) -> Void)? = nil, show: Bool) {
        views.forEach({
            $0.alpha = show ? 0.0 : 1.0
            if show {
                $0.transform = CGAffineTransform(translationX: 0, y: -$0.frame.maxY)
            }
        })
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.15,
                       options: .curveEaseInOut,
                       animations: { () -> Void in
                        views.forEach {
                            $0.transform = show ? .identity : CGAffineTransform(translationX: 0, y: $0.frame.maxY)
                            $0.alpha = show ? 1.0 : 0.0
                        }
        }, completion: completion)
    }
}
