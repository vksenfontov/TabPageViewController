//
//  TabCollectionCell.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

class TabCollectionCell: UICollectionViewCell {

    var tabItemButtonPressedBlock: (() -> Void)?
    var option: TabPageOption = TabPageOption() {
        didSet {
        }
    }
    var item: TabItem! {
        didSet {
//            itemLabel.text = item
//            itemLabel.invalidateIntrinsicContentSize()
            button.setTitle(item?.title, for: .normal)
            button.setImage(item?.defaultImage, for: .normal)
            button.setImage(item?.defaultImage, for: [.normal, .highlighted])
            button.setImage(item?.selectedImage, for: .selected)
            button.setImage(item?.selectedImage, for: [.selected, .highlighted])
            if let _ = item?.selectedImage {
                button.contentEdgeInsets.left = 8
                button.contentEdgeInsets.right = 8
                button.imageEdgeInsets.right = 8
                button.titleEdgeInsets.left = 8
            } else {
                button.contentEdgeInsets = .zero
                button.imageEdgeInsets = .zero
                button.titleEdgeInsets = .zero
            }
            button.setTitleColor(option.defaultColor, for: .normal)
            button.setTitleColor(option.defaultColor, for: [.normal, .highlighted])
            button.setTitleColor(option.currentColor, for: .selected)
            button.setTitleColor(option.currentColor, for: [.selected, .highlighted])
            button.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
            layoutIfNeeded()
        }
    }

    @IBOutlet fileprivate weak var itemLabel: UILabel!
    @IBOutlet fileprivate weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if item.title.count == 0 {
            return CGSize.zero
        }

        return intrinsicContentSize
    }

    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}


// MARK: - View

extension TabCollectionCell {
    override var intrinsicContentSize : CGSize {
        var width: CGFloat = button.intrinsicContentSize.width + option.tabMargin * 2
        if let tabMinWidth = option.tabMinWidth {
            if width < tabMinWidth {
                width = tabMinWidth
            }
        }
        
        let size = CGSize(width: width, height: option.tabHeight)
        return size
    }

    func highlightTitle() {
//        itemLabel.textColor = option.currentColor
//        itemLabel.font = UIFont.boldSystemFont(ofSize: option.fontSize)
        button.isSelected = true
//        button.tintColor = option.defaultColor
    }

    func unHighlightTitle() {
//        itemLabel.textColor = option.defaultColor
//        itemLabel.font = UIFont.systemFont(ofSize: option.fontSize)
        button.isSelected = false
//        button.tintColor = option.currentColor
    }
}


// MARK: - IBAction

extension TabCollectionCell {
    @IBAction fileprivate func tabItemTouchUpInside(_ button: UIButton) {
        tabItemButtonPressedBlock?()
    }
}
