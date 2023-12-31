//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try FeedItemMO.first(with: url, in: context)
                    .map { $0.imageData = data }
                    .map(context.save)
            }
        }
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try FeedItemMO.data(with: url, in: context)
            }
        }
    }
}

private extension FeedItemMO {
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        return try first(with: url, in: context)?.imageData
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> FeedItemMO? {
        let request = FeedItemMO.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(FeedItemMO.imageURL), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension FeedItemMO {
    public override func prepareForDeletion() {
        super.prepareForDeletion()
        guard let imageURL else { return }
        managedObjectContext?.userInfo[imageURL] = imageData
    }
}
