//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 11.10.2023.
//

import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadFeed), for: .valueChanged)
        loadFeed()
    }
    
    @objc private func loadFeed() {
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_loadView_loadsTheFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_manualFeedReload_requestsLoadFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateManualFeedLoad()
        
        XCTAssertEqual(loader.loadCount, 2)
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
        var loadCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCount += 1
        }
    }
}

private extension FeedViewController {
    func simulateManualFeedLoad() {
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
