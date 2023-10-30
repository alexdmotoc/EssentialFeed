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
    
    private lazy var localFeedImageLoader = LocalFeedImageDataLoader(store: store)
    
    private let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.makeFeedController(
            with: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalFeedImageLoaderWithRemoteFallback,
            selection: handleFeedItemSelection
        )
    )
    
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedItem>, Error> {
        let url = FeedEndpoint.get.url(baseURL: baseURL)
        return httpClient
            .getPublisher(at: url)
            .tryMap(FeedItemMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { Paginated(items: $0) }
            .eraseToAnyPublisher()
    }
    
    private func makeLocalFeedImageLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
        localFeedImageLoader
            .loadPublisher(from: url)
            .fallback(to: { [unowned self] in
                httpClient
                    .getPublisher(at: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localFeedImageLoader, for: url)
            })
    }
}
