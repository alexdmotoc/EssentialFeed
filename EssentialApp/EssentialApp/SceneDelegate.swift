//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Alex Motoc on 17.10.2023.
//

import UIKit
import EssentialFeediOS
import EssentialFeed
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let storeURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "feed-store.sqlite")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = makeClient()
        let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        
        let remoteFeedLoader = RemoteFeedLoader(client: client, url: baseURL)
        let localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        let feedLoaderWithCache = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: client)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: feedStore)
        let feedImageLoaderWithCache = FeedImageDataLoaderCacheDecorator(decoratee: remoteFeedImageLoader, cache: localFeedImageLoader)
        
        window?.rootViewController = FeedUIComposer.makeFeedController(
            with: FeedLoaderWithFallbackComposite(
                primary: feedLoaderWithCache,
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localFeedImageLoader,
                fallback: feedImageLoaderWithCache
            )
        )
    }
    
    func makeClient() -> HTTPClient {
        URLSessionHTTPClient()
    }
}

