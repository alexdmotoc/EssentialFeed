//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest
@testable import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(client: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedImages, 2)
        XCTAssertEqual(feed.renderedImageData(at: 0), makeImage0Data())
        XCTAssertEqual(feed.renderedImageData(at: 1), makeImage1Data())
        
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateFeedLoadMoreAction()
        
        XCTAssertEqual(feed.numberOfRenderedImages, 3)
        XCTAssertEqual(feed.renderedImageData(at: 0), makeImage0Data())
        XCTAssertEqual(feed.renderedImageData(at: 1), makeImage1Data())
        XCTAssertEqual(feed.renderedImageData(at: 2), makeImage2Data())
        XCTAssertTrue(feed.canLoadMoreFeed)
        
        feed.simulateFeedLoadMoreAction()
        
        XCTAssertEqual(feed.numberOfRenderedImages, 3)
        XCTAssertEqual(feed.renderedImageData(at: 0), makeImage0Data())
        XCTAssertEqual(feed.renderedImageData(at: 1), makeImage1Data())
        XCTAssertEqual(feed.renderedImageData(at: 2), makeImage2Data())
        XCTAssertFalse(feed.canLoadMoreFeed)
    }
    
    func test_onLaunch_displaysCachedFeedWhenThereIsNoConnectivity() {
        let store = InMemoryFeedStore.empty
        let onlineFeed = launch(client: .online(response), store: store)
        onlineFeed.simulateCellIsVisible(at: 0)
        onlineFeed.simulateCellIsVisible(at: 1)
        
        onlineFeed.simulateFeedLoadMoreAction()
        onlineFeed.simulateCellIsVisible(at: 2)
        
        let offlineFeed = launch(client: .offline, store: store)
        XCTAssertEqual(offlineFeed.numberOfRenderedImages, 3)
        XCTAssertEqual(offlineFeed.renderedImageData(at: 0), makeImage0Data())
        XCTAssertEqual(offlineFeed.renderedImageData(at: 1), makeImage1Data())
        XCTAssertEqual(offlineFeed.renderedImageData(at: 2), makeImage2Data())
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
    
    func test_onFirstImageTap_displaysCommentsForThatImage() {
        let commentsVC = showCommentsAfterSelectingFirstImage()
        
        XCTAssertEqual(commentsVC.numberOfRenderedComments, 1)
        XCTAssertEqual(commentsVC.commentCell(at: 0)?.messageLabel.text, makeCommentMessage())
    }
    
    // MARK: - Helpers
    
    private func launch(client: HTTPClientStub, store: InMemoryFeedStore) -> ListViewController {
        let scene = SceneDelegate(httpClient: client, store: store, coreDataQueue: .immediateOnMainQueue)
        scene.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        scene.configureWindow()
        let nav = scene.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! ListViewController
        feed.simulateAppearance()
        return feed
    }
    
    private func showCommentsAfterSelectingFirstImage() -> ListViewController {
        let feed = launch(client: .online(response), store: .empty)
        
        feed.simulateFeedCellTap(at: 0)
        RunLoop.current.run(until: Date())
        
        let comments = feed.navigationController?.topViewController as! ListViewController
        comments.simulateAppearance()
        return comments
    }
    
    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, coreDataQueue: .immediateOnMainQueue)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func response(for url: URL) -> (HTTPURLResponse, Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, makeData(for: url))
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0": return makeImage0Data()
        case "/image-1": return makeImage1Data()
        case "/image-2": return makeImage2Data()
        case "/essential-feed/v1/image/\(firstImageID)/comments":
            return makeCommentsData()
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=\(lastImageID)") == true:
            return makeSecondPageFeedData()
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=\(secondPageImageID)") == true:
            return makeLastEmptyFeedPageData()
        default:
            return makeFirstPageFeedData()
        }
    }
    
    private func makeImage0Data() -> Data { UIImage.make(withColor: .red).pngData()! }
    private func makeImage1Data() -> Data { UIImage.make(withColor: .green).pngData()! }
    private func makeImage2Data() -> Data { UIImage.make(withColor: .blue).pngData()! }
    
    private func makeFirstPageFeedData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "\(firstImageID)", "image": "http://feed.com/image-0"],
            ["id": "\(lastImageID)", "image": "http://feed.com/image-1"]
        ]])
    }
    
    private func makeSecondPageFeedData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "\(secondPageImageID)", "image": "http://feed.com/image-2"]
        ]])
    }
    
    private func makeLastEmptyFeedPageData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": []])
    }
    
    private func makeCommentsData() -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2020-05-20T11:24:59+0000",
                "author": [
                    "username": "a username"
                ]
            ] as [String: Any],
        ]])
    }
    
    private func makeCommentMessage() -> String {
        "a message"
    }
    
    private let firstImageID = UUID()
    private let lastImageID = UUID()
    private let secondPageImageID = UUID()
}
