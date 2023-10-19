//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Alex Motoc on 19.10.2023.
//

import Foundation
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.saveIgnoringResult(feed)
                return feed
            })
        }
    }
    
    private func saveIgnoringResult(_ feed: [FeedItem]) {
        cache.save(feed) { _ in }
    }
}
