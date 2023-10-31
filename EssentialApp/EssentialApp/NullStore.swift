//
//  NullStore.swift
//  EssentialApp
//
//  Created by Alex Motoc on 31.10.2023.
//

import Foundation
import EssentialFeed

final class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(nil)
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
