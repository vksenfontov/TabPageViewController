//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

public protocol TabPageViewControllerDataSource {
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int
    
    func tabPage(pageViewController: TabPageViewController, indexAt viewController: UIViewController) -> Int
    
    func tabPage(pageViewController: TabPageViewController, viewControllerAt index: Int) -> UIViewController
}

public protocol TabPageViewControllerDelegate {
    
}

open class TabPageViewController: UIViewController {
    open var dataSource: TabPageViewControllerDataSource? = nil
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()
    open var tabItems: [(viewController: UIViewController, title: String)] = []

    var currentIndex: Int? {
        guard let viewController = pageViewController.viewControllers?.first else {
            return nil
        }
        return tabItems.map{ $0.viewController }.index(of: viewController)
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
    fileprivate var tabItemsCount: Int {
        return tabItems.count
    }
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    lazy fileprivate var tabView: TabView = self.configuredTabView()
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?
    fileprivate var tabBarTopConstraint: NSLayoutConstraint?

    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupPageViewController()
        setupScrollView()
        updateNavigationBar()
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

        updateNavigationBar()
        tabView.layouted = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
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

    fileprivate func setupScrollView() {
        // Disable PageViewController's ScrollView bounce
        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.backgroundColor = option.pageBackgoundColor
    }

    /**
     Update NavigationBar
     */

    fileprivate func updateNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(option.tabBackgroundImage, for: .default)
            navigationBar.isTranslucent = option.isTranslucent
        }
    }

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

        tabView.pageTabItems = tabItems.map({ $0.title})
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?._selectedController(index: index, direction: direction, animated: true)
        }

        tabBarTopConstraint = top

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

    public func updateNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        guard let navigationController = navigationController else { return }

        switch option.hidesTopViewOnSwipeType {
        case .tabBar:
            updateTabBarOrigin(hidden: hidden)
        case .navigationBar:
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        case .all:
            updateTabBarOrigin(hidden: hidden)
            if hidden {
                navigationController.setNavigationBarHidden(true, animated: true)
            } else {
                showNavigationBar()
            }
        default:
            break
        }
        if statusView == nil {
            setupStatusView()
        }

        statusViewHeightConstraint!.constant = topLayoutGuide.length
    }

    public func showNavigationBar() {
        guard let navigationController = navigationController else { return }
        guard navigationController.isNavigationBarHidden  else { return }
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }

        if option.hidesTopViewOnSwipeType != .none {
            tabBarTopConstraint.constant = 0.0
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
                self.view.layoutIfNeeded()
            }
        }

        navigationController.setNavigationBarHidden(false, animated: true)
        
    }

    private func updateTabBarOrigin(hidden: Bool) {
        guard let tabBarTopConstraint = tabBarTopConstraint else { return }

        tabBarTopConstraint.constant = hidden ? -(20.0 + option.tabHeight) : 0.0
        UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
            self.view.layoutIfNeeded()
        }
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
        if let currentIndex = currentIndex , currentIndex < tabItemsCount {
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

        // (0..<tabItemsCount)
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            index = beforeIndex + 1
        } else {
            index = beforeIndex - 1
        }
        
        if index == tabItemsCount {
            index = 0
        } else if index < 0 {
            index = tabItemsCount - 1
        }

        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }
}
