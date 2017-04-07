//
//  ValueCell.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation

/// A type that represents a cell that can be reused and configured with a value.
public protocol ValueCell: class {
    associatedtype Value
    static var defaultReusableId: String { get }
    func configureWith(value: Value)
}
