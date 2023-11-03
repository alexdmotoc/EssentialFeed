//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 09.10.2023.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedItem]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    public func load(completion: @escaping (Result<[FeedItem], Error>) -> Void) {
        completion(Result {
            if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                return cache.feed.toModels()
            }
            return []
        })
    }
}

extension LocalFeedLoader {
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCacheError: Error {}
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        completion(ValidationResult {
            do {
                if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    throw InvalidCacheError()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
