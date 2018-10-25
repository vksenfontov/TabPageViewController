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
    public let selectedImage: UIImage?
    public let defaultImage: UIImage?

    public init(title: String, icon: UIImage? = nil, selected: UIImage? = nil, viewController: UIViewController) {
        self.title = title
        self.defaultImage = icon
        self.selectedImage = selected
        self.viewController = viewController
    }
}
