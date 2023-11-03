//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 09.10.2023.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    @available(*, deprecated)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    @available(*, deprecated)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    @available(*, deprecated)
    func retrieve(completion: @escaping RetrievalCompletion)
    
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}

public extension FeedStore {
    func deleteCachedFeed() throws {
        let group = DispatchGroup()
        var receivedError: Error?
        group.enter()
        deleteCachedFeed { error in
            receivedError = error
            group.leave()
        }
        group.wait()
        if let receivedError {
            throw receivedError
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let group = DispatchGroup()
        var receivedError: Error?
        group.enter()
        insert(feed, timestamp: timestamp) { error in
            receivedError = error
            group.leave()
        }
        group.wait()
        if let receivedError {
            throw receivedError
        }
    }
    
    func retrieve() throws -> CachedFeed? {
        let group = DispatchGroup()
        var received: RetrievalResult!
        group.enter()
        retrieve { result in
            received = result
            group.leave()
        }
        group.wait()
        return try received.get()
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
    func retrieve(completion: @escaping RetrievalCompletion) {}
}
