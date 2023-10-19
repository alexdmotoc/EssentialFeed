//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try FeedItemMO.first(with: url, in: context)
                    .map { $0.imageData = data }
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try FeedItemMO.first(with: url, in: context)?.imageData
            })
        }
    }
}

private extension FeedItemMO {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> FeedItemMO? {
        let request = FeedItemMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(FeedItemMO.imageURL), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}