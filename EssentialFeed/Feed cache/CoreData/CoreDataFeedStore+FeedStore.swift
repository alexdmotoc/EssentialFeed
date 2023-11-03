//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                let request = FeedCacheMO.fetchRequest()
                let results = try context.fetch(request)
                for item in results { context.delete(item) }
                try context.save()
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                let existingCache = try context.fetch(FeedCacheMO.fetchRequest())
                for item in existingCache { context.delete(item) }
                
                let feedMO = feed.map {
                    let managedObject = FeedItemMO(context: context)
                    managedObject.id = $0.id
                    managedObject.itemDescription = $0.description
                    managedObject.location = $0.location
                    managedObject.imageURL = $0.url
                    managedObject.imageData = context.userInfo[$0.url] as? Data
                    return managedObject
                }
                
                context.userInfo.removeAllObjects()
                
                let cache = FeedCacheMO(context: context)
                feedMO.forEach { cache.addToFeed($0) }
                cache.timestamp = timestamp
                try context.save()
            }
        }
    }
    
    public func retrieve() throws -> CachedFeed? {
        try performSync { context in
            Result {
                try context.fetch(FeedCacheMO.fetchRequest()).first.map {
                    ($0.localFeed, $0.timestamp!)
                }
            }
        }
    }
}

private extension FeedCacheMO {
    var localFeed: [LocalFeedImage] {
        guard let feed else { return [] }
        return feed
            .compactMap { return $0 as? FeedItemMO }
            .map { LocalFeedImage(id: $0.id!, description: $0.itemDescription, location: $0.location, url: $0.imageURL!) }
    }
}
