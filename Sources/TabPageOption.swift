//
//  TabPageOption.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public enum HidesTopContentsOnSwipeType {
    case none
    case tabBar
    case navigationBar
    case all
}

public struct TabPageOption {

    public init() {}

    public var fontSize = UIFont.systemFontSize
    public var currentColor = UIColor.bubbleGumPink
    public var defaultColor = UIColor.white
    public var tabHeight: CGFloat = 32.0
    public var tabMargin: CGFloat = 20.0
    public var tabMinWidth: CGFloat? = 120
    public var currentBarHeight: CGFloat = 2.0
    public var tabBackgroundColor: UIColor = UIColor.clear
    public var pageBackgoundColor: UIColor = UIColor.white
    public var isTranslucent: Bool = true
    public var hidesTopViewOnSwipeType: HidesTopContentsOnSwipeType = .none

    internal var tabBarAlpha: CGFloat {
        return isTranslucent ? 0.95 : 1.0
    }
    internal var tabBackgroundImage: UIImage {
        return convertImage()
    }

    fileprivate func convertImage() -> UIImage {
        let rect : CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContext? = UIGraphicsGetCurrentContext()
        let backgroundColor = tabBackgroundColor.withAlphaComponent(tabBarAlpha).cgColor
        context?.setFillColor(backgroundColor)
        context?.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
