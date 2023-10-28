//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 11.10.2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp
import Combine

final class CommentsUIIntegrationTests: XCTestCase {
    
    func test_init_doesNotLoadComments() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.commentsLoadCount, 0)
    }
    
    func test_controller_hasTitle() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.title, ImageCommentsPresenter.title)
    }
    
    func test_viewIsAppearingTwice_loadsTheCommentsOnlyOnce() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.commentsLoadCount, 1)
    }
    
    func test_loadingComments_requestsLoadFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.commentsLoadCount, 1, "On first appearance the feed is loaded once")
        
        sut.simulateManualReload()
        XCTAssertEqual(loader.commentsLoadCount, 2, "On manual refresh the feed is loaded again")
        
        sut.simulateManualReload()
        XCTAssertEqual(loader.commentsLoadCount, 3, "On another manual refresh the feed is loaded again")
    }
    
    func test_loadingIndicator_isShownWheneverALoadIsTriggered() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoad(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualReload()
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
        
        sut.simulateManualReload()
        loader.completeFeedLoad(withFeed: [image1, image2, image3, image4], at: 1)
        try assertThat(sut, isRendering: [image1, image2, image3, image4])
    }
    
    func test_loadFeed_rendersEmptyFeedCorrectlyAfterPreviouslyRenderingImages() throws {
        let image1 = makeImage()
        let image2 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        try assertThat(sut, isRendering: [image1, image2])
        
        sut.simulateManualReload()
        loader.completeFeedLoad(withFeed: [], at: 1)
        try assertThat(sut, isRendering: [])
    }
    
    func test_loadFeed_doesNotAlterRenderingOnError() throws {
        let image1 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1], at: 0)
        try assertThat(sut, isRendering: [image1])
        
        sut.simulateManualReload()
        loader.completeFeedLoadWithError(at: 1)
        try assertThat(sut, isRendering: [image1])
    }
    
    func test_feedLoading_dispatchesWorkOnMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        let exp = expectation(description: "wait for complete feed load")
        DispatchQueue.global().async {
            loader.completeFeedLoad(withFeed: [self.makeImage()], at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_feedLoading_showsErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, ResourcePresenter<Any, DummyView>.loadError)
        
        sut.simulateManualReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_onErrorTap_dismissesError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, ResourcePresenter<Any, DummyView>.loadError)
        
        sut.simulateErrorMessageTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    // MARK: - Helpers
    
    private struct DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.makeFeedController(with: loader.loadPublisher)
        checkIsDeallocated(sut: loader, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(
        _ sut: ListViewController,
        isRendering images: [FeedItem],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        sut.view.enforceLayout()
        
        XCTAssertEqual(sut.numberOfRenderedImages, images.count)
        
        try images.enumerated().forEach { index, element in
            try assertThat(sut, isRendering: element, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(
        _ sut: ListViewController,
        isRendering image: FeedItem,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let itemCell = try XCTUnwrap(sut.itemCell(at: index), "Expected to retrieve cell at \(index)", file: file, line: line)
        XCTAssertEqual(itemCell.descriptionText, image.description, "Expected description to match", file: file, line: line)
        XCTAssertEqual(itemCell.isDescriptionHidden, image.description == nil, "Expected description to have same visibility", file: file, line: line)
        XCTAssertEqual(itemCell.locationText, image.location, "Expected location to match", file: file, line: line)
        XCTAssertEqual(itemCell.isLocationHidden, image.location == nil, "Expected location to have the same visibility", file: file, line: line)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "someUrl.com")!) -> FeedItem {
        FeedItem(id: UUID(), description: description, location: location, imageURL: url)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
    
    private class LoaderSpy {
        private var feedPublishers: [PassthroughSubject<[FeedItem], Error>] = []
        private(set) var imageLoadRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        private(set) var cancelledImageLoad: [URL] = []
        var loadedImages: [URL] { imageLoadRequests.map { $0.url } }
        var commentsLoadCount: Int { feedPublishers.count }
        
        // MARK: - FeedLoader
        
        func loadPublisher() -> AnyPublisher<[FeedItem], Error> {
            let subject = PassthroughSubject<[FeedItem], Error>()
            feedPublishers.append(subject)
            return subject.eraseToAnyPublisher()
        }
        
        func completeFeedLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            feedPublishers[index].send(feed)
        }
        
        func completeFeedLoadWithError(at index: Int = 0) {
            feedPublishers[index].send(completion: .failure(NSError(domain: "mock", code: 0)))
        }
    }
}
