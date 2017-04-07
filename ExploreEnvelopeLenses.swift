//
//  ExploreEnvelopeLenses.swift
//  CourseMeta
//
//  Created by JohnP on 3/7/17.
//  Copyright © 2017 JohnP. All rights reserved.
//

import Foundation
import Prelude

extension ExploreEnvelope {
    public enum lens {
        public static let Words = Lens<ExploreEnvelope, [Word]>(
            view: { $0.words },
            set: { ExploreEnvelope(words: $0, urls: $1.urls, stats: $1.stats) }
        )
        public static let urls = Lens<ExploreEnvelope, UrlsEnvelope>(
            view: { $0.urls },
            set: { ExploreEnvelope(words: $1.words, urls: $0, stats: $1.stats) }
        )
        public static let stats = Lens<ExploreEnvelope, StatsEnvelope>(
            view: { $0.stats },
            set: { ExploreEnvelope(words: $1.words, urls: $1.urls, stats: $0) }
        )
    }
}

extension ExploreEnvelope.UrlsEnvelope {
    public enum lens {
        public static let api = Lens<ExploreEnvelope.UrlsEnvelope, ApiEnvelope>(
            view: { $0.api },
            set: { part, _ in ExploreEnvelope.UrlsEnvelope(api: part) }
        )
    }
}

extension ExploreEnvelope.UrlsEnvelope.ApiEnvelope {
    public enum lens {
        public static let moreWords = Lens<ExploreEnvelope.UrlsEnvelope.ApiEnvelope, String>(
            view: { $0.moreWords },
            set: { part, _ in ExploreEnvelope.UrlsEnvelope.ApiEnvelope(more_words: part) }
        )
    }
}

extension ExploreEnvelope.StatsEnvelope {
    public enum lens {
        public static let count = Lens<ExploreEnvelope.StatsEnvelope, Int>(
            view: { $0.count },
            set: { part, _ in ExploreEnvelope.StatsEnvelope(count: part) }
        )
    }
}

extension Lens where Whole == ExploreEnvelope, Part == ExploreEnvelope.UrlsEnvelope {
    public var api: Lens<ExploreEnvelope, ExploreEnvelope.UrlsEnvelope.ApiEnvelope> {
        return ExploreEnvelope.lens.urls • ExploreEnvelope.UrlsEnvelope.lens.api
    }
}

extension Lens where Whole == ExploreEnvelope, Part == ExploreEnvelope.UrlsEnvelope.ApiEnvelope {
    public var moreWords: Lens<ExploreEnvelope, String> {
        return ExploreEnvelope.lens.urls.api • ExploreEnvelope.UrlsEnvelope.ApiEnvelope.lens.moreWords
    }
}
