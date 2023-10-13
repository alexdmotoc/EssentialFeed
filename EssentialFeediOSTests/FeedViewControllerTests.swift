//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 11.10.2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.feedLoadCount, 0)
    }
    
    func test_viewIsAppearingTwice_loadsTheFeedOnlyOnce() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.feedLoadCount, 1)
    }
    
    func test_loadingFeed_requestsLoadFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.feedLoadCount, 1, "On first appearance the feed is loaded once")
        
        sut.simulateManualFeedLoad()
        XCTAssertEqual(loader.feedLoadCount, 2, "On manual refresh the feed is loaded again")
        
        sut.simulateManualFeedLoad()
        XCTAssertEqual(loader.feedLoadCount, 3, "On another manual refresh the feed is loaded again")
    }
    
    func test_loadingIndicator_isShownWheneverALoadIsTriggered() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualFeedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoad(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualFeedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoad(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadFeed_rendersFeedImagesCorrectly() throws {
        let image1 = makeImage(description: nil, location: nil)
        let image2 = makeImage(description: "some desc", location: nil)
        let image3 = makeImage(description: nil, location: "some loc")
        let image4 = makeImage(description: "some desc", location: "some loc")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        try assertThat(sut, isRendering: [])
        
        loader.completeFeedLoad(withFeed: [image1], at: 0)
        try assertThat(sut, isRendering: [image1])
        
        sut.simulateManualFeedLoad()
        loader.completeFeedLoad(withFeed: [image1, image2, image3, image4], at: 1)
        try assertThat(sut, isRendering: [image1, image2, image3, image4])
    }
    
    func test_loadFeed_doesNotAlterRenderingOnError() throws {
        let image1 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1], at: 0)
        try assertThat(sut, isRendering: [image1])
        
        sut.simulateManualFeedLoad()
        loader.completeFeedLoadWithError(at: 1)
        try assertThat(sut, isRendering: [image1])
    }
    
    func test_imageLoading_loadsImageWhenCellIsVisible() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.loadedImages, [])
        
        sut.simulateCellIsVisible(at: 0)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL])
        
        sut.simulateCellIsVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL])
    }
    
    func test_imageLoading_cancelsImageLoadingWhenCellIsNotVisible() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageLoad, [])
        
        sut.simulateCellIsVisible(at: 0)
        sut.simulateCellIsNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageLoad, [image1.imageURL])
        
        sut.simulateCellIsVisible(at: 1)
        sut.simulateCellIsNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageLoad, [image1.imageURL, image2.imageURL])
    }
    
    func test_imageLoading_isShowingLoadingIndicatorWhileImageLoads() throws {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageLoad, [])
        
        let cell0 = sut.simulateCellIsVisible(at: 0)
        let cell1 = sut.simulateCellIsVisible(at: 1)
        
        XCTAssertTrue(cell0.isShowingLoadingIndicator)
        XCTAssertTrue(cell1.isShowingLoadingIndicator)
        
        loader.completeImageLoad(at: 0)
        XCTAssertFalse(cell0.isShowingLoadingIndicator)
        XCTAssertTrue(cell1.isShowingLoadingIndicator)
        
        loader.completeImageLoadWithError(at: 1)
        XCTAssertFalse(cell0.isShowingLoadingIndicator)
        XCTAssertFalse(cell1.isShowingLoadingIndicator)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        checkIsDeallocated(sut: loader, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering images: [FeedItem],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTAssertEqual(sut.numberOfRenderedImages, images.count)
        
        try images.enumerated().forEach { index, element in
            try assertThat(sut, isRendering: element, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering image: FeedItem,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let itemCell = try XCTUnwrap(sut.itemCell(at: index), "Expected to retrieve cell at \(index)", file: file, line: line)
        XCTAssertEqual(itemCell.descriptionText, image.description, file: file, line: line)
        XCTAssertEqual(itemCell.isDescriptionHidden, image.description == nil, file: file, line: line)
        XCTAssertEqual(itemCell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(itemCell.isLocationHidden, image.location == nil, file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "someUrl.com")!) -> FeedItem {
        FeedItem(id: UUID(), description: description, location: location, imageURL: url)
    }
    
    private class LoaderSpy: FeedLoader, FeedImageDataLoader {
        var feedCompletions: [(FeedLoader.Result) -> Void] = []
        var feedLoadCount: Int { feedCompletions.count }
        var imageLoadRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        var loadedImages: [URL] { imageLoadRequests.map { $0.url } }
        var cancelledImageLoad: [URL] = []
        
        // MARK: - FeedLoader
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedCompletions.append(completion)
        }
        
        func completeFeedLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            feedCompletions[index](.success(feed))
        }
        
        func completeFeedLoadWithError(at index: Int = 0) {
            feedCompletions[index](.failure(NSError(domain: "mock", code: 0)))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            let cancelHandler: () -> Void
            func cancel() {
                cancelHandler()
            }
        }
        
        func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageLoadRequests.append((url, completion))
            return FeedImageDataLoaderTaskSpy { [weak self] in self?.cancelledImageLoad.append(url) }
        }
        
        func completeImageLoad(at index: Int = 0) {
            imageLoadRequests[index].completion(.success(Data()))
        }
        
        func completeImageLoadWithError(at index: Int = 0) {
            imageLoadRequests[index].completion(.failure(NSError(domain: "mock", code: 0)))
        }
    }
}

private extension FeedItemCell {
    var descriptionText: String? { descriptionLabel.text }
    var isDescriptionHidden: Bool { descriptionLabel.isHidden }
    var locationText: String? { locationLabel.text }
    var isLocationHidden: Bool { locationContainer.isHidden }
    var isShowingLoadingIndicator: Bool { feedImageContainer.isShimmering }
}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedImages: Int {
        tableView.numberOfRows(inSection: 0)
    }
    
    // MARK: - Initialization support
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForInitialAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func prepareForInitialAppearance() {
        replaceRefreshControlWithSpyForiOS17Support()
    }
    
    func replaceRefreshControlWithSpyForiOS17Support() {
        let spy = UIRefreshControlSpy()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                spy.addTarget(target, action: Selector($0), for: .valueChanged)
            }
        }
        
        refreshControl = spy
    }
    
    // MARK: - Utility
    
    var itemsSection: Int { 0 }
    
    func itemCell(at index: Int) -> FeedItemCell? {
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: itemsSection)) as? FeedItemCell
    }
    
    @discardableResult
    func simulateCellIsVisible(at index: Int) -> FeedItemCell {
        let cell = itemCell(at: index)!
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: itemsSection))
        return cell
    }
    
    func simulateCellIsNotVisible(at index: Int) {
        tableView.delegate?.tableView?(tableView, didEndDisplaying: itemCell(at: index)!, forRowAt: IndexPath(row: index, section: itemsSection))
    }
    
    func simulateManualFeedLoad() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
    private class UIRefreshControlSpy: UIRefreshControl {
        var _isRefreshing: Bool = false
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}
