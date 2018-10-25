//
//  LimitedTabPageViewController.swift
//  TabPageViewController
//
//  Created by Tomoya Hayakawa on 2017/08/05.
//
//

import UIKit
import TabPageViewController

class LimitedTabPageViewController: TabPageViewController {

    let tabItems: [TabItem] = {
        let vc1 = UIViewController()
        vc1.view.backgroundColor = UIColor.white
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListViewController")
        return [
            TabItem(title: "First", viewController: vc1),
            TabItem(title: "Second", viewController: vc2),
        ]
    }()
    
    override init() {
        super.init()
        
        dataSource = self

        
//        option.tabWidth = view.frame.width / CGFloat(tabItems.count)
//        option.hidesTopViewOnSwipeType = .all
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LimitedTabPageViewController: TabMenuViewControllerDataSource {
    func numberOfItemsForTabMenu() -> Int {
        return tabItems.count
    }
    
    func tabMenu(view: UIView, itemForItemAt index: Int) -> TabItem {
        return tabItems[index]
    }
}

extension LimitedTabPageViewController: TabPageViewControllerDataSource {
    func numberOfItemsForTabPage(viewController: TabPageViewController) -> Int {
        return tabItems.count
    }
    
    func tabPageViewController(_ pageViewController: TabPageViewController, indexAt viewController: UIViewController) -> Int {
        guard let index = tabItems.map({$0.viewController}).index(of: viewController) else {
            fatalError("")
        }
        return index
    }
    
    func tabPageViewController(_ pageViewController: TabPageViewController, viewControllerAt index: Int) -> UIViewController {
        return tabItems[index].viewController
    }
}
