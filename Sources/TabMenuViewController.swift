//
//  TabMenuViewController.swift
//  TabPageViewController
//
//  Created by Masayoshi Ukida on 2018/10/11.
//

import UIKit


public protocol TabMenuViewControllerDataSource: class {
    
    func numberOfItemsForTabMenu() -> Int
    
    func tabMenu(view: UIView, itemForItemAt index: Int) -> TabItem
    
    //    func tabMenu(view: UIView, widthForItemAt index: Int) -> CGFloat
}

public protocol TabMenuViewControllerDelegate: class {
    
    func tabMenu(view: UIView, itemForItemAt index: Int) -> TabItem
    func tabMenu(view: UIView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection)
    //    func tabMenu(view: UIView, widthForItemAt index: Int) -> CGFloat
}

public class TabMenuViewController: UIViewController {
    open var dataSource: TabMenuViewControllerDataSource? = nil
    open var delegate: TabMenuViewControllerDelegate? = nil
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()

    var currentIndex: Int = 0
    fileprivate var beforeIndex: Int = 0
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    lazy fileprivate var tabView: TabView = self.configuredTabView()
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tabView.superview == nil {
            tabView = configuredTabView()
        }
        
        if isInfinity {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabView.layouted = true
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /**
     Update NavigationBar
     */
    fileprivate func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: isInfinity, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: tabView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)
        
        let top = NSLayoutConstraint(item: tabView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: tabView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: tabView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        view.addConstraints([top, left, right])
        
        let numberOfItems = dataSource?.numberOfItemsForTabMenu() ?? 0
        var tabItems:[TabItem] = []
        for index in 0 ..< numberOfItems {
            guard let item = dataSource?.tabMenu(view: tabView, itemForItemAt: index) else {
                fatalError("")
            }
            tabItems.append(item)
        }
        
        tabView.pageTabItems = tabItems.map({ $0.title})
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
        
        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?.delegate?.tabMenu(view: self!.view, didSelectItemAt: index, direction: direction)
        }
        
        return tabView
    }
    
    private func setupStatusView() {
        let statusView = UIView()
        statusView.backgroundColor = option.tabBackgroundColor
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
        
        let top = NSLayoutConstraint(item: statusView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .top,
                                     multiplier:1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: statusView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: statusView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        let height = NSLayoutConstraint(item: statusView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: topLayoutGuide.length)
        
        view.addConstraints([top, left, right, height])
        
        statusViewHeightConstraint = height
        self.statusView = statusView
    }

}

extension TabMenuViewController {
    public func selectIndex(index: Int, animated: Bool) {
        tabView.updateCurrentIndex(index, shouldScroll: animated)
    }
}

// MARK: - UIScrollViewDelegate

extension TabMenuViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
            return
        }
        
        let numberOfItems = dataSource?.numberOfItemsForTabMenu() ?? 0
        // (0..<numberOfItems)
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            index = beforeIndex + 1
        } else {
            index = beforeIndex - 1
        }
        
        if index == numberOfItems {
            index = 0
        } else if index < 0 {
            index = numberOfItems - 1
        }

        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }
}
