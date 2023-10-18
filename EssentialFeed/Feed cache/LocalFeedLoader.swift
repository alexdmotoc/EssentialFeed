//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 09.10.2023.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] deleteError in
            guard let self else { return }
            if let deleteError {
                completion(deleteError)
                return
            }
            store.insert(feed.toLocal(), timestamp: currentDate(), completion: completion)
        }
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.none):
                completion(.success([]))
            case .success(.some((let feed, let timestamp))) where FeedCachePolicy.validate(timestamp, against: currentDate()):
                completion(.success(feed.toModels()))
            case .success:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                self.deleteCachedFeed(completion: completion)
            case .success(.some((_, let timestamp))) where !FeedCachePolicy.validate(timestamp, against: currentDate()):
                self.deleteCachedFeed(completion: completion)
            case .success:
                completion(.success(()))
            }
        }
    }
    
    private func deleteCachedFeed(completion: @escaping (ValidationResult) -> Void) {
        store.deleteCachedFeed { error in
            if let error { completion(.failure(error)) }
            else { completion(.success(())) }
        }
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
