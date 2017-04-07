//
//  User.swift
//  Facestar
//
//  Created by JohnP on 2/13/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct User {
    public let avatar: Avatar
    public let facebookConnected: Bool?
    public let id: String
    public let isFriend: Bool?
    public let location: Location?
    public let name: String
    public let notifications: Notifications
    public let social: Bool?
    
    public struct Avatar {
        public let large: String?
        public let medium: String
        public let small: String
    }
    
    public struct Notifications {
        public let backings: Bool?
        public let comments: Bool?
        public let follower: Bool?
        public let friendActivity: Bool?
        public let mobileBackings: Bool?
        public let mobileComments: Bool?
        public let mobileFollower: Bool?
        public let mobileFriendActivity: Bool?
        public let mobilePostLikes: Bool?
        public let mobileUpdates: Bool?
        public let postLikes: Bool?
        public let updates: Bool?
    }
}

extension User: Equatable {}
public func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

extension User: Decodable {
    public static func decode(_ json: JSON) -> Decoded<User> {
        let create = curry(User.init)
        let tmp = create
            <^> json <| "avatar"
            <*> json <|? "facebook_connected"
            <*> json <| "id"
            <*> json <|? "is_friend"
            <*> (json <|? "location" <|> .success(nil))
        return tmp
            <*> json <| "name"
            <*> User.Notifications.decode(json)
            <*> json <|? "social"
    }
}

extension User: EncodableType {
    public func encode() -> [String:Any] {
        var result: [String:Any] = [:]
        result["avatar"] = self.avatar.encode()
        result["facebook_connected"] = self.facebookConnected ?? false
        result["id"] = self.id
        result["is_friend"] = self.isFriend ?? false
        result["location"] = self.location?.encode()
        result["name"] = self.name
        result = result.withAllValuesFrom(self.notifications.encode())
        
        return result
    }
}



extension User.Avatar: Decodable {
    public static func decode(_ json: JSON) -> Decoded<User.Avatar> {
        return curry(User.Avatar.init)
            <^> json <|? "large"
            <*> json <| "medium"
            <*> json <| "small"
    }
}

extension User.Avatar: EncodableType {
    public func encode() -> [String:Any] {
        var ret: [String:Any] = [
            "medium": self.medium,
            "small": self.small
        ]
        
        ret["large"] = self.large
        
        return ret
    }
}

extension User.Notifications: Decodable {
    public static func decode(_ json: JSON) -> Decoded<User.Notifications> {
        let create = curry(User.Notifications.init)
        let tmp1 = create
            <^> json <|? "notify_of_backings"
            <*> json <|? "notify_of_comments"
            <*> json <|? "notify_of_follower"
            <*> json <|? "notify_of_friend_activity"
        let tmp2 = tmp1
            <*> json <|? "notify_mobile_of_backings"
            <*> json <|? "notify_mobile_of_comments"
            <*> json <|? "notify_mobile_of_follower"
            <*> json <|? "notify_mobile_of_friend_activity"
        return tmp2
            <*> json <|? "notify_mobile_of_post_likes"
            <*> json <|? "notify_mobile_of_updates"
            <*> json <|? "notify_of_post_likes"
            <*> json <|? "notify_of_updates"
    }
}

extension User.Notifications: EncodableType {
    public func encode() -> [String:Any] {
        var result: [String:Any] = [:]
        result["notify_of_backings"] = self.backings
        result["notify_of_comments"] = self.comments
        result["notify_of_follower"] = self.follower
        result["notify_of_friend_activity"] = self.friendActivity
        result["notify_of_post_likes"] = self.postLikes
        result["notify_of_updates"] = self.updates
        result["notify_mobile_of_backings"] = self.mobileBackings
        result["notify_mobile_of_comments"] = self.mobileComments
        result["notify_mobile_of_follower"] = self.mobileFollower
        result["notify_mobile_of_friend_activity"] = self.mobileFriendActivity
        result["notify_mobile_of_post_likes"] = self.mobilePostLikes
        result["notify_mobile_of_updates"] = self.mobileUpdates
        return result
    }
}

extension User.Notifications: Equatable {}
public func == (lhs: User.Notifications, rhs: User.Notifications) -> Bool {
    return lhs.backings == rhs.backings &&
        lhs.comments == rhs.comments &&
        lhs.follower == rhs.follower &&
        lhs.friendActivity == rhs.friendActivity &&
        lhs.mobileBackings == rhs.mobileBackings &&
        lhs.mobileComments == rhs.mobileComments &&
        lhs.mobileFollower == rhs.mobileFollower &&
        lhs.mobileFriendActivity == rhs.mobileFriendActivity &&
        lhs.mobilePostLikes == rhs.mobilePostLikes &&
        lhs.mobileUpdates == rhs.mobileUpdates &&
        lhs.postLikes == rhs.postLikes &&
        lhs.updates == rhs.updates
}
