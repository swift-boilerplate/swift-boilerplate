//
//  ExploreParams.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Argo
import Curry
import Runes
import Prelude

public struct ExploreParams {
    public let selected: Bool?
    public let created: Bool?
    
    public static let defaults = ExploreParams(selected: nil, created: nil)
    
    public var queryParams: [String: String] {
        var params: [String:String] = [:]
        
        params["selected"] = self.selected == true ? "1" : self.selected == false ? "-1" : nil
        return params
    }
}

extension ExploreParams: Equatable {}
public func == (a: ExploreParams, b: ExploreParams) -> Bool {
    return a.queryParams == b.queryParams
}

extension ExploreParams: Hashable {
    public var hashValue: Int {
        return self.description.hash
    }
}

extension ExploreParams: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return self.queryParams.description
    }
    
    public var debugDescription: String {
        return self.queryParams.debugDescription
    }
}

extension ExploreParams: Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExploreParams> {
        let create = curry(ExploreParams.init)
        
        let tmp1 = create
            <^> ((json <|? "selected" >>- stringIntToBool) as Decoded<Bool?>)
            <*> ((json <|? "created" >>- stringIntToBool) as Decoded<Bool?>)
        return tmp1
    }
}

private func stringToBool(_ string: String?) -> Decoded<Bool?> {
    guard let string = string else { return .success(nil) }
    switch string {
    // taken from server's `value_to_boolean` function
    case "true", "1", "t", "T", "true", "TRUE", "on", "ON":
        return .success(true)
    case "false", "0", "f", "F", "false", "FALSE", "off", "OFF":
        return .success(false)
    default:
        return .failure(.custom("Could not parse string into bool."))
    }
}

private func stringToInt(_ string: String?) -> Decoded<Int?> {
    guard let string = string else { return .success(nil) }
    return Int(string).map(Decoded.success) ?? .failure(.custom("Could not parse string into int."))
}

private func stringIntToBool(_ string: String?) -> Decoded<Bool?> {
    guard let string = string else { return .success(nil) }
    return Int(string)
        .filter { $0 <= 1 && $0 >= -1 }
        .map { .success($0 == 0 ? nil : $0 == 1) }
        .coalesceWith(.failure(.custom("Could not parse string into bool.")))
}
