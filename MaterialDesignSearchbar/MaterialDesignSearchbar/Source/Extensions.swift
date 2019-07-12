//
//  Extensions.swift
//  MaterialDesignWidgets
//
//  Created by Ho, Tsung Wei on 5/16/19.
//  Copyright © 2019 Michael Ho. All rights reserved.
//

import UIKit

public typealias BtnAction = (() -> Void)

struct Colors {
    static let sand = UIColor(red: 0.94, green: 0.89, blue: 0.77, alpha: 1.0)
}
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
            
            let context = UIGraphicsGetCurrentContext()!
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.setBlendMode(.normal)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context.clip(to: rect, mask: cgImage!)
            
            newColor.setFill()
            context.fill(rect)
            
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
// MARK: - Font
struct Font {
    static let bold = { (size: CGFloat) in
        UIFont(name: "Roboto-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static let regular = { (size: CGFloat) in
        UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
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
