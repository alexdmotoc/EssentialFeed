//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.load(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_init_doesNotMessageDecoratee() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.requestedURLs.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoaderCacheDecorator,
        spy: FeedImageDataLoaderSpy
    ) {
        let spy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: spy)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
}
