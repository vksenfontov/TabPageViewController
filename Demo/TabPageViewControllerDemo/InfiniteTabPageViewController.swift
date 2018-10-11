//
//  InfiniteTabPageViewController.swift
//  TabPageViewController
//
//  Created by Tomoya Hayakawa on 2017/08/05.
//
//

import UIKit
import TabPageViewController

class InfiniteTabPageViewController: UIViewController {
    
    let tabItems: [TabItem] = {
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor(red: 251/255, green: 252/255, blue: 149/255, alpha: 1.0)
        let vc2 = UIViewController()
        vc2.view.backgroundColor = UIColor(red: 252/255, green: 150/255, blue: 149/255, alpha: 1.0)
        let vc3 = UIViewController()
        vc3.view.backgroundColor = UIColor(red: 149/255, green: 218/255, blue: 252/255, alpha: 1.0)
        let vc4 = UIViewController()
        vc4.view.backgroundColor = UIColor(red: 149/255, green: 252/255, blue: 197/255, alpha: 1.0)
        let vc5 = UIViewController()
        vc5.view.backgroundColor = UIColor(red: 252/255, green: 182/255, blue: 106/255, alpha: 1.0)

        return [
            TabItem(title: "Mon.", viewController: vc1),
            TabItem(title: "Tue.", viewController: vc2),
            TabItem(title: "Wed.", viewController: vc3),
            TabItem(title: "Thu.", viewController: vc4),
            TabItem(title: "Fri.", viewController: vc5),
        ]
    }()
    
    var pageViewController: TabPageViewController!
    var menuViewController: TabMenuViewController!
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TabMenuViewController {
            menuViewController = controller
            menuViewController.isInfinity = true
            menuViewController.dataSource = self
            menuViewController.delegate = self
        }
        else if let controller = segue.destination as? TabPageViewController {
            pageViewController = controller
            pageViewController.dataSource = self
            pageViewController.delegate = self
        }
    }
}

extension InfiniteTabPageViewController: TabMenuViewControllerDataSource {
    func numberOfItemsForTabMenu() -> Int {
        return tabItems.count
    }
    
    func tabMenu(view: UIView, itemForItemAt index: Int) -> TabItem {
        return tabItems[index]
    }
}

extension InfiniteTabPageViewController: TabMenuViewControllerDelegate {
    func tabMenu(view: UIView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection) {
        pageViewController.selectedController(index: index, direction: direction, animated: true)
    }
}

extension InfiniteTabPageViewController: TabPageViewControllerDataSource {
    func tabPageViewController(_ pageViewController: TabPageViewController, indexAt viewController: UIViewController) -> Int {
        guard let index = tabItems.map({$0.viewController}).index(of: viewController) else {
            fatalError("")
        }
        return index
    }
    
    func tabPageViewController(_ pageViewController: TabPageViewController, viewControllerAt index: Int) -> UIViewController {
        return tabItems[index].viewController
    }
    
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int {
        return tabItems.count
    }
}

extension InfiniteTabPageViewController: TabPageViewControllerDelegate {
    func tabPageViewController(_ viewController: TabPageViewController, willBeginPagingAt index: Int, animated: Bool) {
        print("willBeginPagingAt: \(index)")
    }
    
    func tabPageViewController(_ viewController: TabPageViewController, didFinishPagingAt index: Int, animated: Bool) {
        print("didFinishPagingAt: \(index)")
        menuViewController.selectIndex(index: index, animated: true)
    }
    
    
    
//        let numberOfItems = dataSource?.numberOfItemsForTabPage(viewController: self) ?? 0
//        if let currentIndex = currentIndex , currentIndex < numberOfItems {
//            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
//            beforeIndex = currentIndex
//        }
//
//        tabView.updateCollectionViewUserInteractionEnabled(true)
    
}
