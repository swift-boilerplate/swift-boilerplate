//
//  KeyValueStoreType.swift
//  Facestar
//
//  Created by JohnP on 2/22/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

public enum AppKeys: String {
    case closedFacebookConnectInActivity = "com.facestar.KeyValueStoreType.closedFacebookConnectInActivity"
    case closedFindFriendsInActivity = "com.facestar.KeyValueStoreType.closedFindFriendsInActivity"
    case favoriteCategoryIds = "favorite_category_ids"
    case hasSeenFavoriteCategoryAlert = "com.facestar.KeyValueStoreType.hasSeenFavoriteCategoryAlert"
    case lastSeenActivitySampleId = "com.facestar.KeyValueStoreType.lastSeenActivitySampleId"
    case seenAppRating = "com.facestar.KeyValueStoreType.hasSeenAppRating"
    case seenGamesNewsletter = "com.facestar.KeyValueStoreType.hasSeenGamesNewsletter"
}

public protocol KeyValueStoreType: class {
    func setBool(_ bool: Bool, forKey key: String)
    func setInteger(_ int: Int, forKey key: String)
    func set(_ value: Any?, forKey defaultName: String)
    
    func boolForKey(_ key: String) -> Bool
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func integerForKey(_ key: String) -> Int
    func object(forKey defaultName: String) -> Any?
    func stringForKey(_ key: String) -> String?
    func synchronize() -> Bool
    
    func removeObjectForKey(_ key: String)
    
    var favoriteCategoryIds: [Int] { get set }
    var hasClosedFacebookConnectInActivity: Bool { get set }
    var hasClosedFindFriendsInActivity: Bool { get set }
    var hasSeenAppRating: Bool { get set }
    var hasSeenFavoriteCategoryAlert: Bool { get set }
    var hasSeenGamesNewsletterPrompt: Bool { get set }
    var lastSeenActivitySampleId: Int { get set }
}

extension KeyValueStoreType {
    public var favoriteCategoryIds: [Int] {
        get {
            return self.object(forKey: AppKeys.favoriteCategoryIds.rawValue) as? [Int] ?? []
        }
        set {
            self.set(newValue, forKey: AppKeys.favoriteCategoryIds.rawValue)
        }
    }
    
    public var hasClosedFacebookConnectInActivity: Bool {
        get {
            return self.object(forKey: AppKeys.closedFacebookConnectInActivity.rawValue) as? Bool ?? false
        }
        set {
            self.set(newValue, forKey: AppKeys.closedFacebookConnectInActivity.rawValue)
        }
    }
    
    public var hasClosedFindFriendsInActivity: Bool {
        get {
            return self.object(forKey: AppKeys.closedFindFriendsInActivity.rawValue) as? Bool ?? false
        }
        set {
            self.set(newValue, forKey: AppKeys.closedFindFriendsInActivity.rawValue)
        }
    }
    
    public var hasSeenAppRating: Bool {
        get {
            return self.boolForKey(AppKeys.seenAppRating.rawValue)
        }
        set {
            self.setBool(newValue, forKey: AppKeys.seenAppRating.rawValue)
        }
    }
    
    public var hasSeenFavoriteCategoryAlert: Bool {
        get {
            return self.boolForKey(AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
        }
        set {
            self.setBool(newValue, forKey: AppKeys.hasSeenFavoriteCategoryAlert.rawValue)
        }
    }
    
    public var hasSeenGamesNewsletterPrompt: Bool {
        get {
            return self.boolForKey(AppKeys.seenGamesNewsletter.rawValue)
        }
        set {
            self.setBool(newValue, forKey: AppKeys.seenGamesNewsletter.rawValue)
        }
    }
    
    public var lastSeenActivitySampleId: Int {
        get {
            return self.integerForKey(AppKeys.lastSeenActivitySampleId.rawValue)
        }
        set {
            self.setInteger(newValue, forKey: AppKeys.lastSeenActivitySampleId.rawValue)
        }
    }
}

extension UserDefaults: KeyValueStoreType {
}

extension NSUbiquitousKeyValueStore: KeyValueStoreType {
    public func integerForKey(_ key: String) -> Int {
        return Int(longLong(forKey: key))
    }
    
    public func setInteger(_ int: Int, forKey key: String) {
        return set(Int64(int), forKey: key)
    }
}

internal class MockKeyValueStore: KeyValueStoreType {
    var store: [String:Any] = [:]
    
    func setBool(_ bool: Bool, forKey key: String) {
        self.store[key] = bool
    }
    
    func setInteger(_ int: Int, forKey key: String) {
        self.store[key] = int
    }
    
    func set(_ value: Any?, forKey key: String) {
        self.store[key] = value
    }
    
    func boolForKey(_ key: String) -> Bool {
        return self.store[key] as? Bool ?? false
    }
    
    func integerForKey(_ key: String) -> Int {
        return self.store[key] as? Int ?? 0
    }
    
    func object(forKey key: String) -> Any? {
        return self.store[key]
    }
    
    func stringForKey(_ key: String) -> String? {
        return self.object(forKey: key) as? String
    }
    
    func dictionary(forKey key: String) -> [String:Any]? {
        return self.object(forKey: key) as? [String:Any]
    }
    
    func removeObjectForKey(_ key: String) {
        self.set(nil, forKey: key)
    }
    
    func synchronize() -> Bool {
        return true
    }
}
