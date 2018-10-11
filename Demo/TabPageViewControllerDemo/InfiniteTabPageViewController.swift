//
//  InfiniteTabPageViewController.swift
//  TabPageViewController
//
//  Created by Tomoya Hayakawa on 2017/08/05.
//
//

import UIKit
import TabPageViewController

class InfiniteTabPageViewController: TabPageViewController {
    
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
    
    override init() {
        super.init()
        
        isInfinity = true
        option.currentColor = UIColor(red: 246/255, green: 175/255, blue: 32/255, alpha: 1.0)
        option.tabMargin = 30.0
        
        menuDataSource = self
        dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension InfiniteTabPageViewController: TabPageViewControllerDataSource {
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int {
        return tabItems.count
    }

    func tabPage(pageViewController: TabPageViewController, indexAt viewController: UIViewController) -> Int {
        guard let index = tabItems.map({$0.viewController}).index(of: viewController) else {
            fatalError("")
        }
        return index
    }
    
    func tabPage(pageViewController: TabPageViewController, viewControllerAt index: Int) -> UIViewController {
        return tabItems[index].viewController
    }
}
