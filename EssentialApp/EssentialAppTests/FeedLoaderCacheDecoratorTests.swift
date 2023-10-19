//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 19.10.2023.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    func save(_ feed: [FeedItem], completion: @escaping (Error?) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get()) ?? []) { _ in }
            completion(result)
        }
    }
}

final class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTests {
    
    func test_load_deliversFeedOnSuccess() {
        let feed = uniqueImageFeed().models
        let sut = makeSUT(stub: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnFailure() {
        let sut = makeSUT(stub: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_cache_cachesFeedOnLoadSuccess() {
        let feed = uniqueImageFeed().models
        let cache = CacheSpy()
        let sut = makeSUT(stub: .success(feed), cache: cache)
        
        sut.load { _ in }
        
        XCTAssertEqual(cache.messages, [.save(feed: feed)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        stub: FeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderCacheDecorator {
        let loader = FeedLoaderStub(stub: stub)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: loader, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        enum Message: Equatable {
            case save(feed: [FeedItem])
        }
        
        private(set) var messages: [Message] = []
        
        func save(_ feed: [FeedItem], completion: @escaping (Error?) -> Void) {
            messages.append(.save(feed: feed))
        }
    }
}
