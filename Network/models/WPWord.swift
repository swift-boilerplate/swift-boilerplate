//
//  Word.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct Word {
    public let id: String
    public let label: String
    public let spell: String
    public let define: String
    public let exactMatches: Int
    public let savedCount: Int
    
    
    public struct Avatar {
        public let large: String?
        public let medium: String
        public let small: String
    }
}

extension Word: Equatable {}
public func == (lhs: Word, rhs: Word) -> Bool {
    return lhs.id == rhs.id
}

extension Word: Decodable {
    static public func decode(_ json: JSON) -> Decoded<Word> {
        let create = curry(Word.init)
        let tmp1 = create
            <^> json <| "id"
            <*> json <| "label"
            <*> json <| "spell"
            <*> json <| "define"
            <*> json <| "exact_matches"
            <*> json <| "saved_count"
        return tmp1
    }
}
