//
//  WordEnvelopeLenses.swift
//  Boilerplate
//
//  Created by JohnP on 4/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Prelude

extension WordEnvelope {
    public enum lens {
        public static let Words = Lens<WordEnvelope, [Word]>(
            view: { $0.words },
            set: { WordEnvelope(words: $0, urls: $1.urls, stats: $1.stats) }
        )
        public static let urls = Lens<WordEnvelope, UrlsEnvelope>(
            view: { $0.urls },
            set: { WordEnvelope(words: $1.words, urls: $0, stats: $1.stats) }
        )
        public static let stats = Lens<WordEnvelope, StatsEnvelope>(
            view: { $0.stats },
            set: { WordEnvelope(words: $1.words, urls: $1.urls, stats: $0) }
        )
    }
}

extension WordEnvelope.UrlsEnvelope {
    public enum lens {
        public static let api = Lens<WordEnvelope.UrlsEnvelope, ApiEnvelope>(
            view: { $0.api },
            set: { part, _ in WordEnvelope.UrlsEnvelope(api: part) }
        )
    }
}

extension WordEnvelope.UrlsEnvelope.ApiEnvelope {
    public enum lens {
        public static let moreWords = Lens<WordEnvelope.UrlsEnvelope.ApiEnvelope, String>(
            view: { $0.moreWords },
            set: { part, _ in WordEnvelope.UrlsEnvelope.ApiEnvelope(more_words: part) }
        )
    }
}

extension WordEnvelope.StatsEnvelope {
    public enum lens {
        public static let count = Lens<WordEnvelope.StatsEnvelope, Int>(
            view: { $0.count },
            set: { part, _ in WordEnvelope.StatsEnvelope(count: part) }
        )
    }
}

extension Lens where Whole == WordEnvelope, Part == WordEnvelope.UrlsEnvelope {
    public var api: Lens<WordEnvelope, WordEnvelope.UrlsEnvelope.ApiEnvelope> {
        return WordEnvelope.lens.urls • WordEnvelope.UrlsEnvelope.lens.api
    }
}

extension Lens where Whole == WordEnvelope, Part == WordEnvelope.UrlsEnvelope.ApiEnvelope {
    public var moreWords: Lens<WordEnvelope, String> {
        return WordEnvelope.lens.urls.api • WordEnvelope.UrlsEnvelope.ApiEnvelope.lens.moreWords
    }
}
