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
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewIsAppearingTwice_loadsTheFeedOnlyOnce() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_loadingFeed_requestsLoadFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCount, 1, "On first appearance the feed is loaded once")
        
        sut.simulateManualFeedLoad()
        XCTAssertEqual(loader.loadCount, 2, "On manual refresh the feed is loaded again")
        
        sut.simulateManualFeedLoad()
        XCTAssertEqual(loader.loadCount, 3, "On another manual refresh the feed is loaded again")
    }
    
    func test_loadingIndicator_isShownWheneverALoadIsTriggered() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualFeedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoad(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualFeedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeLoad(at: 2)
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
        
        loader.completeLoad(withFeed: [image1], at: 0)
        try assertThat(sut, isRendering: [image1])
        
        sut.simulateManualFeedLoad()
        loader.completeLoad(withFeed: [image1, image2, image3, image4], at: 1)
        try assertThat(sut, isRendering: [image1, image2, image3, image4])
    }
    
    func test_loadFeed_doesNotAlterRenderingOnError() throws {
        let image1 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeLoad(withFeed: [image1], at: 0)
        try assertThat(sut, isRendering: [image1])
        
        sut.simulateManualFeedLoad()
        loader.completeLoadWithError(at: 1)
        try assertThat(sut, isRendering: [image1])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
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
    
    private func makeImage(description: String?, location: String?) -> FeedItem {
        FeedItem(id: UUID(), description: description, location: location, imageURL: URL(string: "someUrl.com")!)
    }
    
    private class LoaderSpy: FeedLoader {
        var completions: [(FeedLoader.Result) -> Void] = []
        var loadCount: Int { completions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            completions[index](.success(feed))
        }
        
        func completeLoadWithError(at index: Int = 0) {
            completions[index](.failure(NSError(domain: "mock", code: 0)))
        }
    }
}

private extension FeedItemCell {
    var descriptionText: String? { descriptionLabel.text }
    var isDescriptionHidden: Bool { descriptionLabel.isHidden }
    var locationText: String? { locationLabel.text }
    var isLocationHidden: Bool { locationContainer.isHidden }
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
    
    func itemCell(at index: Int) -> FeedItemCell? {
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: 0)) as? FeedItemCell
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
