//
//  RootViewModel.swift
//  Boilerplate
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude
import UIKit

internal struct TabBarItemsData {
    internal let items: [TabBarItem]
    internal let isLoggedIn: Bool
    internal let isMember: Bool
}

internal enum TabBarItem {
    case home(index: Int)
    case activity(index: Int)
    case dashboard(index: Int)
    case profile(index: Int)
}

internal struct userState {
    internal let isMember: Bool = true
    internal let isLoggedIn: Bool = true
}

internal protocol RootViewModelInputs {
    
    /// Call when selected tab bar index changes.
    func didSelectIndex(_ index: Int)
    
    /// Call when we should switch to the login tab.
    func switchToLogin()
    
    /// Call when we should switch to the profile tab.
    func switchToProfile()
    
    /// Call when the controller has received a user session ended notification.
    func userSessionEnded()
    
    /// Call when the controller has received a user session started notification.
    func userSessionStarted()
    
    /// Call from the controller's `viewDidLoad` method.
    func viewDidload()
}

internal protocol RootViewModelOutputs {
    var setViewControllers: Signal<[UIViewController], NoError> { get }
    /// Emits data for setting tab bar item styles.
    var tabBarItemsData: Signal<TabBarItemsData, NoError> { get }
    
    /// Emits an index that the tab bar should be switched to.
    var selectedIndex: Signal<Int, NoError> { get }
}

internal protocol RootViewModelType {
    var inputs: RootViewModelInputs { get }
    var outputs: RootViewModelOutputs { get }
}

internal final class RootViewModel: RootViewModelType, RootViewModelInputs, RootViewModelOutputs {
    /// Call from the controller's `viewDidLoad` method.
    fileprivate let viewDidLoadProperty = MutableProperty()
    internal func viewDidload() {
        self.viewDidLoadProperty.value = ()
    }

    internal init() {
        let currentUser = Signal.merge(
            self.viewDidLoadProperty.signal,
            self.userSessionStartedProperty.signal,
            self.userSessionEndedProperty.signal,
            self.currentUserUpdatedProperty.signal
            )
            .map { AppEnvironment.current.currentUser }
        let userState: Signal<(isLoggedIn: Bool, isMember: Bool), NoError> = currentUser
            .map { ($0 != nil, true) }
            .skipRepeats(==)
        
        let standardViewControllers = self.viewDidLoadProperty.signal
            .map { _ in
                [
                    HomeViewController.instantiate(),
                    ProfileViewController.instantiate()
                ]
            }

        let personalizedViewControllers = userState
            .map { user in
                [
                    user.isMember   ? DashboardViewController.instantiate() as UIViewController? : nil,
                    user.isLoggedIn ? LoginToutViewController.instantiate() as UIViewController? : nil,
                ]
            }

        let viewControllers = Signal.combineLatest(standardViewControllers, standardViewControllers).map(+)

        self.setViewControllers = viewControllers
            .map { $0.map(UINavigationController.init(rootViewController:)) }
        
        let loginState = userState.map { $0.isLoggedIn }
        let vcCount = self.setViewControllers.map { $0.count }
        
        let switchToLogin = Signal.combineLatest(vcCount, loginState)
            .takeWhen(self.switchToLoginProperty.signal)
            .filter { isFalse($1) }
            .map(first)
        
        let switchToProfile = Signal.combineLatest(vcCount, loginState)
            .takeWhen(self.switchToProfileProperty.signal)
            .filter { isTrue($1) }
            .map(first)
        
        self.selectedIndex =
            Signal.combineLatest(
                .merge(
                    self.didSelectIndexProperty.signal,
                    self.switchToDiscoveryProperty.signal.mapConst(0),
                    self.switchToSearchProperty.signal.mapConst(2),
                    switchToLogin,
                    switchToProfile,
                    self.switchToDashboardProperty.signal.mapConst(3)
                ),
                self.setViewControllers,
                self.viewDidLoadProperty.signal)
                .map { idx, vcs, _ in clamp(0, vcs.count - 1)(idx) }
        
        self.tabBarItemsData = Signal.combineLatest(currentUser, self.viewDidLoadProperty.signal)
            .map(first)
            .map(tabData(forUser: ))
    }
    // Inputs
    fileprivate let currentUserUpdatedProperty = MutableProperty(())
    internal func currentUserUpdated() {
        self.currentUserUpdatedProperty.value = ()
    }
    fileprivate let didSelectIndexProperty = MutableProperty(0)
    internal func didSelectIndex(_ index: Int) {
        self.didSelectIndexProperty.value = index
    }
    fileprivate let switchToDashboardProperty = MutableProperty()
    internal func switchToDashboard() {
        self.switchToDashboardProperty.value = ()
    }
    fileprivate let switchToDiscoveryProperty = MutableProperty()
    internal func switchToDiscovery() {
        self.switchToDiscoveryProperty.value = ()
    }
    fileprivate let switchToLoginProperty = MutableProperty()
    internal func switchToLogin() {
        self.switchToLoginProperty.value = ()
    }
    fileprivate let switchToProfileProperty = MutableProperty()
    internal func switchToProfile() {
        self.switchToProfileProperty.value = ()
    }
    fileprivate let switchToSearchProperty = MutableProperty()
    internal func switchToSearch() {
        self.switchToSearchProperty.value = ()
    }
    fileprivate let userSessionStartedProperty = MutableProperty<()>()
    internal func userSessionStarted() {
        self.userSessionStartedProperty.value = ()
    }
    fileprivate let userSessionEndedProperty = MutableProperty<()>()
    internal func userSessionEnded() {
        self.userSessionEndedProperty.value = ()
    }
    
    // Outputs
    internal let setViewControllers: Signal<[UIViewController], NoError>
    internal let selectedIndex: Signal<Int, NoError>
    internal let tabBarItemsData: Signal<TabBarItemsData, NoError>
    
    // Type
    internal var inputs: RootViewModelInputs { return self }
    internal var outputs: RootViewModelOutputs { return self }
}

private func tabData(forUser user: User?) -> TabBarItemsData {
    let items: [TabBarItem] = [
        .home(index: 0),
        .activity(index: 1),
        .dashboard(index: 2),
        .profile(index: 3)
    ]

    return TabBarItemsData(items: items, isLoggedIn: true, isMember: true)
}

extension TabBarItemsData: Equatable { }
func == (lhs: TabBarItemsData, rhs: TabBarItemsData) -> Bool {
    return lhs.items == rhs.items &&
    lhs.isMember == rhs.isMember &&
    lhs.isLoggedIn == rhs.isLoggedIn
}

extension TabBarItem: Equatable { }
func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
    switch (lhs, rhs) {
    case let (.activity(lhs), .activity(rhs)):
        return lhs == rhs
    case let (.dashboard(lhs), .dashboard(rhs)):
        return lhs == rhs
    case let (.home(lhs), .home(rhs)):
        return lhs == rhs
    case let (.profile(lhs), .profile(rhs)):
        return lhs == rhs
    default: return false
    }
}

private func first<VC: UIViewController>(_ viewController: VC.Type) -> ([UIViewController]) -> VC? {

    return { viewControllers in
        viewControllers
            .index { $0 is VC }
            .flatMap { viewControllers[$0] as? VC }
    }
}








