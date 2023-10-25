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
import Combine

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
    
    private lazy var remoteFeedLoader: RemoteFeedLoader = {
        let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        return RemoteFeedLoader(client: httpClient, url: baseURL)
    }()
    
    private lazy var remoteFeedImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    private lazy var localFeedImageLoader = LocalFeedImageDataLoader(store: store)
    
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
        let feedController = FeedUIComposer.makeFeedController(
            with: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalFeedImageLoaderWithRemoteFallback
        )
        
        window?.rootViewController = UINavigationController(rootViewController: feedController)
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> RemoteFeedLoader.Publisher {
        remoteFeedLoader
            .loadPublisher()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
        localFeedImageLoader
            .loadPublisher(from: url)
            .fallback(to: { [unowned self] in
                remoteFeedImageLoader
                    .loadPublisher(from: url)
                    .caching(to: localFeedImageLoader, for: url)
            })
    }
}
