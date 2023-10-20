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
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
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
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebugHTTPClient(connectivity: connectivity)
        }
        return URLSessionHTTPClient()
    }
}

private class DebugHTTPClient: HTTPClient {
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeGetResponse(for: url)))
        default:
            completion(.failure(NSError(domain: "debug error", code: 0)))
        }
        return Task()
    }
    
    private func makeGetResponse(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, makeData(for: url))
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let image = UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            UIColor.red.setFill()
            rendererContext.fill(rect)
        }
        
        return image.pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}

