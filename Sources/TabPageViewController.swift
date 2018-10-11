//
//  TabPageViewController.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit



public protocol TabPageViewControllerDataSource: class {
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int
    
    func tabPageViewController(_ pageViewController: TabPageViewController,
                               indexAt viewController: UIViewController) -> Int
    
    func tabPageViewController(_ pageViewController: TabPageViewController,
                               viewControllerAt index: Int) -> UIViewController
    
}

public protocol TabPageViewControllerDelegate: class {
    
    func tabPageViewController(_ viewController: TabPageViewController,
                               willBeginPagingAt index: Int,
                               animated: Bool)

    func tabPageViewController(_ viewController: TabPageViewController,
                               didFinishPagingAt index: Int,
                               animated: Bool)
}

open class TabPageViewController: UIViewController {
    open var dataSource: TabPageViewControllerDataSource? = nil
    open var delegate: TabPageViewControllerDelegate? = nil
    public fileprivate(set) var selectedIndex: Int = 0
    private var toIndex: Int = 0

    fileprivate lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [:]
        )
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()

    
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
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}


// MARK: - Public Interface

public extension TabPageViewController {

    public func selectedController(index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let nextViewController = dataSource?.tabPageViewController(self, viewControllerAt: index) else {
            return
        }
        
        let completion: ((Bool) -> Void) = { [weak self] _ in
            self?.selectedIndex = index
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
        selectedIndex = 0
        guard let viewController = dataSource?.tabPageViewController(self, viewControllerAt: selectedIndex) else {
            fatalError("")
        }
        pageViewController.setViewControllers(
            [viewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
}


// MARK: - UIPageViewControllerDataSource

extension TabPageViewController: UIPageViewControllerDataSource {
    fileprivate func nextIndex(_ viewController: UIViewController, isAfter: Bool) -> Int? {
        guard let count = dataSource?.numberOfItemsForTabPage(viewController: self) else {
            return nil
        }

        guard var index = dataSource?.tabPageViewController(self, indexAt: viewController) else {
            return nil
        }
        
        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        index = (index + count) % count
        
        return index
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = nextIndex(viewController, isAfter: true) else {
            return nil
        }
        return dataSource?.tabPageViewController(self, viewControllerAt: index)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = nextIndex(viewController, isAfter: false) else {
            return nil
        }
        return dataSource?.tabPageViewController(self, viewControllerAt: index)
    }
   
}


// MARK: - UIPageViewControllerDelegate

extension TabPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let to = pendingViewControllers.first, let toIndex = dataSource?.tabPageViewController(self, indexAt: to) else {
            return
        }
        self.toIndex = toIndex
        self.delegate?.tabPageViewController(self,
                                             willBeginPagingAt: toIndex,
                                             animated: true)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        selectedIndex = toIndex
        self.delegate?.tabPageViewController(self,
                                             didFinishPagingAt: selectedIndex,
                                             animated: true)
    }
}


