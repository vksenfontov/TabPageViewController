//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public protocol TabMenuViewControllerDataSource: class {
    
    func numberOfItemsForTabMenu() -> Int
    
    func tabMenu(view: UIView, itemForItemAt index: Int) -> TabItem
    
//    func tabMenu(view: UIView, widthForItemAt index: Int) -> CGFloat
}

public protocol TabPageViewControllerDataSource {
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int
    
    func tabPage(pageViewController: TabPageViewController, indexAt viewController: UIViewController) -> Int
    
    func tabPage(pageViewController: TabPageViewController, viewControllerAt index: Int) -> UIViewController
}

public protocol TabPageViewControllerDelegate {
    
}

open class TabPageViewController: UIViewController {
    open var menuDataSource: TabMenuViewControllerDataSource? = nil
    open var dataSource: TabPageViewControllerDataSource? = nil
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()

    var currentIndex: Int? {
        guard let viewController = pageViewController.viewControllers?.first else {
            return nil
        }
        return dataSource?.tabPage(pageViewController: self, indexAt: viewController)
    }
    fileprivate lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [:]
        )
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    fileprivate var beforeIndex: Int = 0
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    lazy fileprivate var tabView: TabView = self.configuredTabView()
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?

    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupPageViewController()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if tabView.superview == nil {
            tabView = configuredTabView()
        }

        if let currentIndex = currentIndex , isInfinity {
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
}


// MARK: - Public Interface

public extension TabPageViewController {

    public func selectedController(index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        _selectedController(index: index, direction: direction, animated: animated)
        guard isViewLoaded else { return }
        tabView.updateCurrentIndex(index, shouldScroll: true)
    }
    
    func _selectedController(index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        beforeIndex = index
        shouldScrollCurrentBar = false
        guard let nextViewController = dataSource?.tabPage(pageViewController: self, viewControllerAt: index) else {
            return
        }
        
        let completion: ((Bool) -> Void) = { [weak self] _ in
            self?.shouldScrollCurrentBar = true
            self?.beforeIndex = index
        }
        
        pageViewController.setViewControllers(
            [nextViewController],
            direction: direction,
            animated: animated,
            completion: completion
        )
    }
}


// MARK: - View

extension TabPageViewController {

    fileprivate func setupPageViewController() {
        let pageView = pageViewController.view!
        pageViewController.willMove(toParent: self)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.topAnchor.constraint(equalTo: pageView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: pageView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: pageView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: pageView.bottomAnchor).isActive = true
        pageViewController.didMove(toParent: self)
        
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.automaticallyAdjustsScrollViewInsets = false
        guard let viewController = dataSource?.tabPage(pageViewController: self, viewControllerAt: beforeIndex) else {
            fatalError("")
        }
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
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

        let numberOfItems = menuDataSource?.numberOfItemsForTabMenu() ?? 0
        var tabItems:[TabItem] = []
    for index in 0 ..< numberOfItems {
        guard let item = menuDataSource?.tabMenu(view: tabView, itemForItemAt: index) else {
            fatalError("")
        }
        tabItems.append(item)
    }
    
        tabView.pageTabItems = tabItems.map({ $0.title})
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?._selectedController(index: index, direction: direction, animated: true)
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


// MARK: - UIPageViewControllerDataSource

extension TabPageViewController: UIPageViewControllerDataSource {
    fileprivate func nextIndex(_ viewController: UIViewController, isAfter: Bool) -> Int? {
        guard let count = dataSource?.numberOfItemsForTabPage(viewController: self) else {
            return nil
        }

        guard var index = dataSource?.tabPage(pageViewController: self, indexAt: viewController) else {
            return nil
        }
        
        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        if isInfinity {
            if index < 0 {
                index = count - 1
            } else if index == count {
                index = 0
            }
        }
        
        return index
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = nextIndex(viewController, isAfter: true) else {
            return nil
        }
        return dataSource?.tabPage(pageViewController: self, viewControllerAt: index)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = nextIndex(viewController, isAfter: false) else {
            return nil
        }
        return dataSource?.tabPage(pageViewController: self, viewControllerAt: index)
    }
   
}


// MARK: - UIPageViewControllerDelegate

extension TabPageViewController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollCurrentBar = true
        tabView.scrollToHorizontalCenter()

        // Order to prevent the the hit repeatedly during animation
        tabView.updateCollectionViewUserInteractionEnabled(false)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let numberOfItems = dataSource?.numberOfItemsForTabPage(viewController: self) ?? 0
        if let currentIndex = currentIndex , currentIndex < numberOfItems {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
            beforeIndex = currentIndex
        }

        tabView.updateCollectionViewUserInteractionEnabled(true)
    }
}


// MARK: - UIScrollViewDelegate

extension TabPageViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
            return
        }
        
        let numberOfItems = dataSource?.numberOfItemsForTabPage(viewController: self) ?? 0
        
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
