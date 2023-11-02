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
import os

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var storeURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appending(path: "feed-store.sqlite")
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient()
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(storeURL: storeURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var localFeedImageLoader = LocalFeedImageDataLoader(store: store)
    
    private let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.makeFeedController(
            with: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalFeedImageLoaderWithRemoteFallback,
            selection: handleFeedItemSelection
        )
    )
    
    private lazy var logger = Logger(subsystem: "com.alexdmotoc.EssentialFeed", category: "main")
    
    private lazy var coreDataQueue: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.alexdmotoc.coreDataQueue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    convenience init(
        httpClient: HTTPClient,
        store: FeedStore & FeedImageDataStore,
        coreDataQueue: AnyDispatchQueueScheduler
    ) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.coreDataQueue = coreDataQueue
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // MARK: - Navigation
    
    private func handleFeedItemSelection(_ item: FeedItem) {
        let controller = CommentsUIComposer.makeCommentsController(with: { [unowned self] in makeCommentsLoader(item) })
        navigationController.pushViewController(controller, animated: true)
    }
    
    // MARK: - Factories
    
    private func makeCommentsLoader(_ item: FeedItem) -> AnyPublisher<[ImageComment], Error> {
        let url = ImageCommentsEndpoont.get(item.id).url(baseURL: baseURL)
        return httpClient
            .getPublisher(at: url)
            .tryMap(ImageCommentsMapper.map)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after item: FeedItem? = nil) -> AnyPublisher<[FeedItem], Error> {
        let url = FeedEndpoint.get(after: item).url(baseURL: baseURL)
        return httpClient
            .getPublisher(at: url)
            .tryMap(FeedItemMapper.map)
            .eraseToAnyPublisher()
    }
    
    /// This is an exercise to demonstrate how we can load first from cache and then load from remote (unused)
//    private func makeLocalFeedLoaderWithRemoteContinuation() -> AnyPublisher<Paginated<FeedItem>, Error> {
//        let cachePublisher = localFeedLoader
//            .loadPublisher()
//            .map { self.makePage(items: $0, last: nil) }
//        
//        let remotePublisher = makeRemoteFeedLoaderWithLocalFallback()
//            .delay(for: 10, scheduler: DispatchQueue.main)
//        
//        let combinedPublisher = cachePublisher
//            .append(remotePublisher)
//            .eraseToAnyPublisher()
//        
//        return combinedPublisher
//    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedItem>, Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedItem?) -> AnyPublisher<Paginated<FeedItem>, Error> {
        localFeedLoader
            .loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }
            .map(makePage)
            .caching(to: localFeedLoader)
            .eraseToAnyPublisher()
    }
    
    private func makePage(items: [FeedItem], last: FeedItem?) -> Paginated<FeedItem> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func makeFirstPage(items: [FeedItem]) -> Paginated<FeedItem> {
        makePage(items: items, last: items.last)
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
        localFeedImageLoader
            .loadPublisher(from: url)
            .fallback(to: { [unowned self] in
                httpClient
                    .getPublisher(at: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localFeedImageLoader, for: url)
                    .subscribe(on: coreDataQueue)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: coreDataQueue)
            .eraseToAnyPublisher()
    }
}
