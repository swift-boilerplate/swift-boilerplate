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
    public let location: String
    public let social: Bool?
    
    public struct Avatar {
        public let large: String?
        public let medium: String
        public let small: String
    }
}

extension User: Equatable {}
public func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
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
