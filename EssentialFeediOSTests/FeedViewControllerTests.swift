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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        checkIsDeallocated(sut: loader, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class LoaderSpy: FeedLoader {
        var completions: [(FeedLoader.Result) -> Void] = []
        var loadCount: Int { completions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoad(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
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
