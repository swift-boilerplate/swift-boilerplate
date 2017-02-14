//
//  NSBundle-Framework.swift
//  Facestar
//
//  Created by JohnP on 2/11/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
extension Bundle {
    /// Returns an NSBundle pinned to the framework target. We could choose anything for the `forClass`
    /// parameter as long as it is in the framework target.
    internal static var framework: Bundle {
        return Bundle(for: RootViewModel.self)
    }
}
