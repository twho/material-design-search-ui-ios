//
//  Extensions.swift
//  MaterialDesignWidgets
//
//  Created by Ho, Tsung Wei on 5/16/19.
//  Copyright © 2019 Michael Ho. All rights reserved.
//

import UIKit

public typealias BtnAction = (() -> Void)

// MARK: - UIImage
extension UIImage {
    /**
     Change the color of the image.
     
     - Parameter color: The color to be set to the UIImage.
     
     Returns an UIImage with specified color
     */
    public func colored(_ color: UIColor?) -> UIImage? {
        if let newColor = color {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            // Init context
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            // Init rect
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            // Draw color
            newColor.setFill()
            context.fill(rect)
            // Generate new image
            let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            newImage.accessibilityIdentifier = accessibilityIdentifier
            return newImage
        }
        return self
    }
}

extension UIStackView {
    /**
     Convenient initializer.
     
     - Parameter arrangedSubviews: all arranged subviews to be put to the stack.
     - Parameter axis: The arranged axis of the stack view.
     - Parameter distribution: The distribution of the stack view.
     - Parameter spacing: The spacing between each view in the stack view.
     */
    convenience init(arrangedSubviews: [UIView]? = nil, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat) {
        if let arrangedSubviews = arrangedSubviews {
            self.init(arrangedSubviews: arrangedSubviews)
        } else {
            self.init()
        }
        (self.axis, self.spacing, self.distribution) = (axis, spacing, distribution)
    }
}
// MARK: - NSObject
extension NSObject {
    /**
     We assume the AppDelegate exists in the entire life cycle of the app.
     */
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate).unsafelyUnwrapped
    }
}
// MARK: - MaterialButton
extension MaterialButton {
    /**
     Convenience init of theme button with just icon.
     
     - Parameter icon:         the icon of the button, it is be nil by default.
     - Parameter bgColor:      the background color of the button, tint color will be automatically generated.
     - Parameter cornerRadius: the rounded corner radius of the button.
     */
    public convenience init(icon: UIImage, bgColor: UIColor = .black, cornerRadius: CGFloat = 12.0) {
        self.init(icon: icon, bgColor: bgColor, cornerRadius: cornerRadius, withShadow: false)
    }
}
// MARK: - UIView
extension UIView {
    /**
     Make the specified view (in parameter) to be centered of current view.
     
     - Parameter view: The view to be positioned to the center of current view.
     */
    public func centerSubView(_ view: UIView) {
        self.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)]
        )
    }
    /**
     Add subviews and make it prepared for AutoLayout.
     
     - Parameter views: The views to be added as subviews of current view.
     */
    public func addSubViews(_ views: [UIView]) {
        views.forEach({
            self.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
    }
    /**
     Set layout constraints of top, bottom, left, and right bounds.
     
     - Parameter top:    The view that the current view references as the top view.
     - Parameter tConst: The constant to be applied to the top constraint.
     - Parameter bottom: The view that the current view references as the bottom view.
     - Parameter bConst: The constant to be applied to the bottom constraint.
     - Parameter left:   The view that the current view references as the left view.
     - Parameter lConst: The constant to be applied to the left constraint.
     - Parameter right:  The view that the current view references as the right view.
     - Parameter rConst: The constant to be applied to the right constraint.
     */
    public func setConstraintsToView(top: UIView? = nil, tConst: CGFloat = 0,
                                     bottom: UIView? = nil, bConst: CGFloat = 0,
                                     left: UIView? = nil, lConst: CGFloat = 0,
                                     right: UIView? = nil, rConst: CGFloat = 0) {
        guard let suView = self.superview else { return }
        // Set top constraints if the view is specified.
        if let top = top {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .top,
                                   relatedBy: .equal,
                                   toItem: top, attribute: .top,
                                   multiplier: 1.0, constant: tConst)
            )
        }
        // Set bottom constraints if the view is specified.
        if let bottom = bottom {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .bottom,
                                   relatedBy: .equal,
                                   toItem: bottom, attribute: .bottom,
                                   multiplier: 1.0, constant: bConst)
            )
        }
        // Set left constraints if the view is specified.
        if let left = left {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .left,
                                   relatedBy: .equal,
                                   toItem: left, attribute: .left,
                                   multiplier: 1.0, constant: lConst)
            )
        }
        // Set right constraints if the view is specified.
        if let right = right {
            suView.addConstraint(
                NSLayoutConstraint(item: self, attribute: .right,
                                   relatedBy: .equal,
                                   toItem: right, attribute: .right,
                                   multiplier: 1.0, constant: rConst)
            )
        }
    }
}
// MARK: - UILabel
extension UILabel {
    /**
     Convenience initializers of UILable for app-wide use.
     
     - Parameter title:    The title of the label.
     - Parameter size:     The font size.
     - Parameter color:    The text color.
     - Parameter bold:     The flag to decide if use bold font.
     - Parameter lines:    The number of lines of the label.
     - Parameter aligment: The text alignment of the the label.
     */
    public convenience init(title: String, size: CGFloat, color: UIColor, bold: Bool = false, lines: Int, aligment: NSTextAlignment) {
        self.init()
        self.text = title
        self.font = bold ? ResManager.Font.bold(size) : ResManager.Font.regular(size)
        self.textColor = color
        self.numberOfLines = lines
        self.textAlignment = aligment
    }
}
