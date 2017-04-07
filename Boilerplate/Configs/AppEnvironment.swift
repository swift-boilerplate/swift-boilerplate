//
//  AppEnvironment.swift
//  Boilerplate
//
//  Created by JohnP on 2/13/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

public struct AppEnvironment {
    fileprivate static var stack: [Environment] = [Environment()]
    public static var current: Environment! {
        return stack.last
    }
}

public struct Environment {
    let currentUser: User?
    public init(
        currentUser: User? = nil
        ) {
        self.currentUser = currentUser
    }
}
