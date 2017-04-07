//
//  ExploreEnvelope.swift
//  CourseMeta
//
//  Created by JohnP on 3/6/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

public struct ExploreEnvelope {
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

extension ExploreEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExploreEnvelope> {
        return curry(ExploreEnvelope.init)
            <^> json <|| "words"
            <*> json <|  "urls"
            <*> json <| "stats"
    }
}

extension ExploreEnvelope.UrlsEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExploreEnvelope.UrlsEnvelope> {
        return curry(ExploreEnvelope.UrlsEnvelope.init)
            <^> json <| "api"
    }
}

extension ExploreEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExploreEnvelope.UrlsEnvelope.ApiEnvelope> {
        return curry(ExploreEnvelope.UrlsEnvelope.ApiEnvelope.init)
            <^> json <| "more_words"
    }
}

extension ExploreEnvelope.StatsEnvelope: Decodable {
    public static func decode(_ json: JSON) -> Decoded<ExploreEnvelope.StatsEnvelope> {
        return curry(ExploreEnvelope.StatsEnvelope.init)
            <^> json <| "count"
    }
}
