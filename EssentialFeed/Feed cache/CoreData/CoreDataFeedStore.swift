//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 09.10.2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            let request = FeedCacheMO.fetchRequest()
            do {
                let results = try context.fetch(request)
                for item in results { context.delete(item) }
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let existingCache = try context.fetch(FeedCacheMO.fetchRequest())
                for item in existingCache { context.delete(item) }
                
                let feedMO = feed.map {
                    let managedObject = FeedItemMO(context: context)
                    managedObject.id = $0.id
                    managedObject.itemDescription = $0.description
                    managedObject.location = $0.location
                    managedObject.imageURL = $0.url
                    return managedObject
                }
                
                let cache = FeedCacheMO(context: context)
                feedMO.forEach { cache.addToFeed($0) }
                cache.timestamp = timestamp
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try context.fetch(FeedCacheMO.fetchRequest()).first.map {
                    ($0.localFeed, $0.timestamp!)
                }
            })
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
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
