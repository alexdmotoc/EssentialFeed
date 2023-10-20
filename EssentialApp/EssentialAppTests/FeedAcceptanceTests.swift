//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(client: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedImages, 2)
        XCTAssertEqual(feed.renderedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedFeedWhenThereIsNoConnectivity() {
        let store = InMemoryFeedStore.empty
        let onlineFeed = launch(client: .online(response), store: store)
        onlineFeed.simulateCellIsVisible(at: 0)
        onlineFeed.simulateCellIsVisible(at: 1)
        
        let offlineFeed = launch(client: .offline, store: store)
        XCTAssertEqual(offlineFeed.numberOfRenderedImages, 2)
        XCTAssertEqual(offlineFeed.renderedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedOnEmptyCacheAndNoConnectivity() {
        let offlineFeed = launch(client: .offline, store: .empty)
        XCTAssertEqual(offlineFeed.numberOfRenderedImages, 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    // MARK: - Helpers
    
    private func launch(client: HTTPClientStub, store: InMemoryFeedStore) -> FeedViewController {
        let scene = SceneDelegate(httpClient: client, store: store)
        scene.window = UIWindow()
        scene.configureWindow()
        let nav = scene.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! FeedViewController
        feed.simulateAppearance()
        return feed
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func response(for url: URL) -> (HTTPURLResponse, Data) {
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
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
