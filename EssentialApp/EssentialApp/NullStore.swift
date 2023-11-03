//
//  NullStore.swift
//  EssentialApp
//
//  Created by Alex Motoc on 31.10.2023.
//

import Foundation
import EssentialFeed

final class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed() throws {
        
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        
    }
    
    func retrieve() throws -> CachedFeed? {
        .none
    }
    
    func insert(_ data: Data, for url: URL) throws {
        
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
}
