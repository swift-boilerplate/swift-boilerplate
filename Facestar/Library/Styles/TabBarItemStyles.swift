//
//  TabBarItemStyles.swift
//  Facestar
//
//  Created by JohnP on 2/14/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Prelude
import Prelude_UIKit
import UIKit

public let tabBarDeselectedColor = UIColor.gray
public let tabBarSelectedColor = UIColor.red
public let tabBarTintColor = UIColor.white
public let tabBarAvatarSize = CGSize(width: 25, height: 25)

private let paddingY: CGFloat = 6.0

private let baseTabBarItemStyle = UITabBarItem.lens.title .~ nil
    <> UITabBarItem.lens.imageInsets .~ .init(top: paddingY, left: 0.0, bottom: -paddingY, right: 0.0)
    <> UITabBarItem.lens.titlePositionAdjustment .~ UIOffset(horizontal: 0, vertical: 9_999_999)

public func activityTabBarItemStyle(isMember: Bool) -> (UITabBarItem) -> UITabBarItem {
    let offset: CGFloat = isMember ? 4.0 : 9.0
    
    return baseTabBarItemStyle
        <> UITabBarItem.lens.image .~ UIImage(named: "tabbar-icon-activity")
        <> UITabBarItem.lens.selectedImage .~ UIImage(named: "tabbar-icon-activity-selected")
        <> UITabBarItem.lens.title .~ "Activity"
        <> UITabBarItem.lens.imageInsets .~ .init(top: paddingY, left: -offset, bottom: -paddingY, right: offset)
}

public let dashboardTabBarItemStyle = baseTabBarItemStyle
    <> UITabBarItem.lens.image .~ UIImage(named: "tabbar-icon-dashboard")
    <> UITabBarItem.lens.selectedImage .~ UIImage(named: "tabbar-icon-dashboard-selected")
    <> UITabBarItem.lens.title .~ "Dashboard"

public func homeTabBarItemStyle(isMember: Bool) -> (UITabBarItem) -> UITabBarItem {
    let offset: CGFloat = isMember ? 4.0 : 13.0
    
    return baseTabBarItemStyle
        <> UITabBarItem.lens.image .~ UIImage(named: "star-filled-icon")
        <> UITabBarItem.lens.selectedImage .~ UIImage(named: "star-filled-icon")
        <> UITabBarItem.lens.title .~ "Home"
        <> UITabBarItem.lens.imageInsets .~ .init(top: paddingY, left: -offset, bottom: -paddingY, right: offset)
}

public func profileTabBarItemStyle(isLoggedIn: Bool, isMember: Bool) -> (UITabBarItem) -> UITabBarItem {
    
    let offset: CGFloat = isMember ? 2.0 : 12.0
    let imageName = isLoggedIn ? "tabbar-icon-profile-logged-in" : "tabbar-icon-profile-logged-out"
    let accLabel = isLoggedIn ? "Profile" : "Log in"
    
    return baseTabBarItemStyle
        <> UITabBarItem.lens.image .~ UIImage(named: imageName)
        <> UITabBarItem.lens.selectedImage .~ UIImage(named: "tabbar-icon-profile-selected")
        <> UITabBarItem.lens.title .~ "Profile"
        <> UITabBarItem.lens.imageInsets .~ .init(top: paddingY, left: offset, bottom: -paddingY, right: -offset)
}

public let searchTabBarItemStyle = baseTabBarItemStyle
    <> UITabBarItem.lens.image .~ UIImage(named: "tabbar-icon-search")
    <> UITabBarItem.lens.selectedImage .~ UIImage(named: "tabbar-icon-search-selected")
    <> UITabBarItem.lens.title .~  "Search"
