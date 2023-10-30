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

final class FeedUIIntegrationTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.feedLoadCount, 0)
    }
    
    func test_controller_hasTitle() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.title, FeedPresenter.title)
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
        
        sut.simulateManualReload()
        XCTAssertEqual(loader.feedLoadCount, 2, "On manual refresh the feed is loaded again")
        
        sut.simulateManualReload()
        XCTAssertEqual(loader.feedLoadCount, 3, "On another manual refresh the feed is loaded again")
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
    
    func test_imageLoading_rendersImageWhenLoadedSuccessfully() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        
        let cell0 = sut.simulateCellIsVisible(at: 0)
        let cell1 = sut.simulateCellIsVisible(at: 1)
        XCTAssertEqual(cell0.renderedImageData, nil)
        XCTAssertEqual(cell1.renderedImageData, nil)
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoad(withData: imageData0, at: 0)
        XCTAssertEqual(cell0.renderedImageData, imageData0)
        XCTAssertEqual(cell1.renderedImageData, nil)
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoad(withData: imageData1, at: 1)
        XCTAssertEqual(cell0.renderedImageData, imageData0)
        XCTAssertEqual(cell1.renderedImageData, imageData1)
    }
    
    func test_imageLoading_showsRetryButtonOnLoadImageError() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        
        let cell0 = sut.simulateCellIsVisible(at: 0)
        let cell1 = sut.simulateCellIsVisible(at: 1)
        XCTAssertTrue(cell0.isRetryButtonHidden)
        XCTAssertTrue(cell1.isRetryButtonHidden)
        
        loader.completeImageLoad(withData: UIImage.make(withColor: .red).pngData()!, at: 0)
        XCTAssertTrue(cell0.isRetryButtonHidden)
        XCTAssertTrue(cell1.isRetryButtonHidden)
        
        loader.completeImageLoadWithError(at: 1)
        XCTAssertTrue(cell0.isRetryButtonHidden)
        XCTAssertFalse(cell1.isRetryButtonHidden)
    }
    
    func test_imageLoading_showsRetryButtonOnInvalidImageData() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        
        let cell0 = sut.simulateCellIsVisible(at: 0)
        let cell1 = sut.simulateCellIsVisible(at: 1)
        XCTAssertTrue(cell0.isRetryButtonHidden)
        XCTAssertTrue(cell1.isRetryButtonHidden)
        
        loader.completeImageLoad(withData: Data("invalid image data".utf8), at: 0)
        XCTAssertFalse(cell0.isRetryButtonHidden)
        XCTAssertTrue(cell1.isRetryButtonHidden)
        
        loader.completeImageLoadWithError(at: 1)
        XCTAssertFalse(cell0.isRetryButtonHidden)
        XCTAssertFalse(cell1.isRetryButtonHidden)
    }
    
    func test_imageLoading_retriesImageLoadWhenRetryButtonPressed() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.loadedImages, [])
        
        let cell0 = sut.simulateCellIsVisible(at: 0)
        let cell1 = sut.simulateCellIsVisible(at: 1)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL])
        
        loader.completeImageLoadWithError(at: 0)
        loader.completeImageLoadWithError(at: 1)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL])
        
        cell0.simulateRetryAction()
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL, image1.imageURL])
        
        cell1.simulateRetryAction()
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL, image1.imageURL, image2.imageURL])
    }
    
    func test_imageLoading_preloadsImagesWhenNearlyVisible() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.loadedImages, [])
        
        sut.simulateCellPreload(at: 0)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL])
        
        sut.simulateCellPreload(at: 1)
        XCTAssertEqual(loader.loadedImages, [image1.imageURL, image2.imageURL])
    }
    
    func test_imageLoading_cancelsPreloadingImagesWhenNotVisible() {
        let image1 = makeImage(url: URL(string: "https://some-url-1.com")!)
        let image2 = makeImage(url: URL(string: "https://some-url-2.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        XCTAssertEqual(loader.cancelledImageLoad, [])
        
        sut.simulateCancelCellPreload(at: 0)
        XCTAssertEqual(loader.cancelledImageLoad, [image1.imageURL])
        
        sut.simulateCancelCellPreload(at: 1)
        XCTAssertEqual(loader.cancelledImageLoad, [image1.imageURL, image2.imageURL])
    }
    
    func test_imageLoading_doesNotChangeImageWhenCellIsOutOfScreen() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [makeImage()], at: 0)
        
        sut.simulateCellIsVisible(at: 0)
        let cell = sut.simulateCellIsNotVisible(at: 0)
        loader.completeImageLoad(withData: UIImage.make(withColor: .red).pngData()!, at: 0)
        XCTAssertEqual(cell.renderedImageData, nil)
    }
    
    func test_imageLoading_doesNotShowDataFromPreviousRequestAfterCellIsReused() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [makeImage()], at: 0)
        
        let cell = sut.simulateCellIsVisible(at: 0)
        cell.prepareForReuse()
        
        loader.completeImageLoad(withData: UIImage.make(withColor: .red).pngData()!, at: 0)
        XCTAssertEqual(cell.renderedImageData, nil)
    }
    
    func test_imageLoading_loadsCorrectImageForCellThatWasRedisplayed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [makeImage()], at: 0)
        
        sut.simulateCellIsVisible(at: 0)
        let cell = sut.simulateCellIsNotVisible(at: 0)
        sut.simulateCellIsRedisplayed(cell, at: 0)
        
        loader.completeImageLoad(withData: UIImage.make(withColor: .red).pngData()!, at: 1)
        XCTAssertNotNil(cell.renderedImageData)
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
    
    func test_imageLoading_dispatchesWorkOnMainThread() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [makeImage()], at: 0)
        sut.simulateCellIsVisible(at: 0)
        
        let exp = expectation(description: "wait for complete feed load")
        DispatchQueue.global().async {
            loader.completeImageLoad(at: 0)
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
    
    func test_onImageCellTap_returnsTappedImageCell() {
        let image1 = makeImage()
        let image2 = makeImage()
        var tappedImages: [FeedItem] = []
        let (sut, loader) = makeSUT { tappedImages.append($0) }
        
        sut.simulateAppearance()
        loader.completeFeedLoad(withFeed: [image1, image2], at: 0)
        
        sut.simulateFeedCellTap(at: 0)
        XCTAssertEqual(tappedImages, [image1])
        
        sut.simulateFeedCellTap(at: 1)
        XCTAssertEqual(tappedImages, [image1, image2])
    }
    
    func test_loadMore_requestsLoadMoreFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoad()
        XCTAssertEqual(loader.feedLoadMoreCount, 0, "After feed completes load more is not fired")
        
        sut.simulateFeedLoadMoreAction()
        XCTAssertEqual(loader.feedLoadMoreCount, 1, "Load more is called after first load more action")
        
        sut.simulateFeedLoadMoreAction()
        XCTAssertEqual(loader.feedLoadMoreCount, 1, "Load more is not called while load is still in progress")
        
        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateFeedLoadMoreAction()
        XCTAssertEqual(loader.feedLoadMoreCount, 2, "Expected request after load more completed with more pages")
        
        loader.completeLoadMoreWithError(at: 1)
        sut.simulateFeedLoadMoreAction()
        XCTAssertEqual(loader.feedLoadMoreCount, 3, "Expected request after load more failure")
        
        loader.completeLoadMore(lastPage: true, at: 2)
        sut.simulateFeedLoadMoreAction()
        XCTAssertEqual(loader.feedLoadMoreCount, 3, "Expected no request after loading all pages")
    }
    
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once view is loaded")
        
        loader.completeFeedLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateFeedLoadMoreAction()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")
        
        loader.completeLoadMore(at: 0)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes successfully")
        
        sut.simulateFeedLoadMoreAction()
        XCTAssertTrue(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")
        
        loader.completeLoadMoreWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    // MARK: - Helpers
    
    private struct DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    private func makeSUT(
        selection: @escaping (FeedItem) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.makeFeedController(
            with: loader.loadPublisher,
            imageLoader: loader.loadPublisher,
            selection: selection
        )
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
        let itemCell = try XCTUnwrap(sut.feedCell(at: index), "Expected to retrieve cell at \(index)", file: file, line: line)
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
}
