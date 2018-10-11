//
//  TabItem.swift
//  TabPageViewController
//
//  Created by Masayoshi Ukida on 2018/10/11.
//

import UIKit


public struct TabItem {
    public let title: String
    public let viewController: UIViewController
    
    public init(title: String, viewController: UIViewController) {
        self.title = title
        self.viewController = viewController
    }
}
