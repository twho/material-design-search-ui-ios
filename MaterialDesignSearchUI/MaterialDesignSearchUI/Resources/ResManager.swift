//
//  ResManager.swift
//  MaterialDesignSearchbar
//
//  Created by Ho, Tsung Wei on 7/14/19.
//  Copyright © 2019 Ho, Tsungwei. All rights reserved.
//

import UIKit

class ResManager {
    // MARK: - Colors
    struct Colors {
        static let sand = UIColor(red: 0.94, green: 0.89, blue: 0.77, alpha: 1.0)
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
    
    static let placemarkIcon = { (poi: [String]?) -> UIImage in
        guard let poi = poi, poi.count > 0 else { return #imageLiteral(resourceName: "ic_destination") }
        switch poi {
        case let str where str.contains("cafe"), let str where str.contains("coffee"):
            return #imageLiteral(resourceName: "ic_coffee")
        case let str where str.contains("gas"):
            return #imageLiteral(resourceName: "ic_gas")
        case let str where str.contains("parking"):
            return #imageLiteral(resourceName: "ic_parking")
        case let str where str.contains("airport"):
            return #imageLiteral(resourceName: "ic_airport")
        case let str where str.contains("restaurant"):
            return #imageLiteral(resourceName: "ic_restaurant")
        case let str where str.contains("shop"):
            return #imageLiteral(resourceName: "ic_shopping")
        default:
            return #imageLiteral(resourceName: "ic_location")
        }
    }
}
