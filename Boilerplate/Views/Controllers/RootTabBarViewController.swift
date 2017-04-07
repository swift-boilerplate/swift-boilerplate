//
//  RootTabBarViewController.swift
//  Boilerplate
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import UIKit
import Prelude

class RootTabBarViewController: UITabBarController {
    fileprivate let viewModel: RootViewModelType = RootViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.viewModel.inputs.viewDidload()
    }
    
    override public func bindStyles() {
        super.bindStyles()
        
        _ = self.tabBar
            |> UITabBar.lens.tintColor .~ tabBarSelectedColor
            |> UITabBar.lens.barTintColor .~ tabBarTintColor
    }
    override public func bindViewModel() {
        super.bindViewModel()
        
        self.viewModel.outputs.setViewControllers
            .observeForUI()
            .observeValues { [weak self] in self?.setViewControllers($0, animated: false) }
        
        self.viewModel.outputs.selectedIndex
            .observeForUI()
            .observeValues { [weak self] in self?.selectedIndex = $0 }
        
        self.viewModel.outputs.tabBarItemsData
            .observeForUI()
            .observeValues { [weak self] in self?.setTabBarItemStyles(withData: $0) }
    }

    fileprivate func setTabBarItemStyles(withData data: TabBarItemsData) {
        data.items.forEach { item in
            switch item {
            case let .home(index):
                _ = tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
            case let .dashboard(index):
                _ = tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
            case let .activity(index):
                _ = tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
            case let .profile(index):
                _ = tabBarItem(atIndex: index) ?|> homeTabBarItemStyle(isMember: data.isMember)
                
            }
        }
    }
    
    fileprivate func tabBarItem(atIndex index: Int) -> UITabBarItem? {
        if (self.tabBar.items?.count ?? 0) > index {
            if let item = self.tabBar.items?[index] {
                return item
            }
        }
        return nil
    }
    
}


extension RootTabBarViewController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController,
                                 didSelect viewController: UIViewController) {
        self.viewModel.inputs.didSelectIndex(tabBarController.selectedIndex)
    }
}
