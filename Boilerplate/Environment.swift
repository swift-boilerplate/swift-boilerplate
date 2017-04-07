//
//  Environment.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import AVFoundation
import Foundation
import ReactiveSwift
import Result
import FBSDKCoreKit

public struct Environment {
    public let apiService: ServiceType
    /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
    public let apiDelayInterval: DispatchTimeInterval
    public let config: Config?
    
    public let scheduler: DateScheduler
    
    /// A delegate to handle Facebook initialization and incoming url requests
    public let facebookAppDelegate: FacebookAppDelegateProtocol
    
    /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
    public let ubiquitousStore: KeyValueStoreType
    
    /// A type that exposes how to interface with an NSBundle. Default value is `Bundle.main`.
    public let mainBundle: NSBundleType
    
    /// A user defaults key-value store. Default value is `NSUserDefaults.standard`.
    public let userDefaults: KeyValueStoreType
    
    let currentUser: User?
    public init(
        apiService: ServiceType = Service(),
        apiDelayInterval: DispatchTimeInterval = .seconds(0),
        config: Config? = nil,
        currentUser: User? = nil,
        scheduler: DateScheduler = QueueScheduler.main,
        facebookAppDelegate: FacebookAppDelegateProtocol = FBSDKApplicationDelegate.sharedInstance(),
        ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default(),
        mainBundle: NSBundleType = Bundle.main,
        userDefaults: KeyValueStoreType = UserDefaults.standard
        ) {
        self.apiService = apiService
        self.apiDelayInterval = apiDelayInterval
        self.config = config
        self.currentUser = currentUser
        self.scheduler = scheduler
        self.facebookAppDelegate = facebookAppDelegate
        self.ubiquitousStore = ubiquitousStore
        self.mainBundle = mainBundle
        self.userDefaults = userDefaults
    }
    
    
}
