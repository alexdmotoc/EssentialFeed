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
    
    private lazy var storeURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appending(path: "feed-store.sqlite")
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient()
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: storeURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteFeedLoader = RemoteFeedLoader(client: httpClient, url: baseURL)
        let feedLoaderWithCache = FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
        
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        let feedImageLoaderWithCache = FeedImageDataLoaderCacheDecorator(decoratee: remoteFeedImageLoader, cache: localFeedImageLoader)
        
        let feedController = FeedUIComposer.makeFeedController(
            with: FeedLoaderWithFallbackComposite(
                primary: feedLoaderWithCache,
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localFeedImageLoader,
                fallback: feedImageLoaderWithCache
            )
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
}

