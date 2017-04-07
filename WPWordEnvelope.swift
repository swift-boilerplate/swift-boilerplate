//
//  WordEnvelope.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct WordEnvelope {
    public let words: [Word]
    public let urls: UrlsEnvelope
    public let stats: StatsEnvelope
    
    public struct UrlsEnvelope {
        public let api: ApiEnvelope
        
        public struct ApiEnvelope {
            public let moreWords: String
            
            public init(more_words: String) {
                moreWords = more_words
            }
        }
    }
    
    public struct StatsEnvelope {
        public let count: Int
    }
}

extension WordEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<WordEnvelope> {
        return curry(WordEnvelope.init)
            <^> json <|| "words"
            <*> json <|  "urls"
            <*> json <| "stats"
    }
}

extension WordEnvelope.UrlsEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<WordEnvelope.UrlsEnvelope> {
        return curry(WordEnvelope.UrlsEnvelope.init)
            <^> json <| "api"
    }
}

extension WordEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<WordEnvelope.UrlsEnvelope.ApiEnvelope> {
        return curry(WordEnvelope.UrlsEnvelope.ApiEnvelope.init)
            <^> json <| "more_words"
    }
}

extension WordEnvelope.StatsEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<WordEnvelope.StatsEnvelope> {
        return curry(WordEnvelope.StatsEnvelope.init)
            <^> json <| "count"
    }
}
