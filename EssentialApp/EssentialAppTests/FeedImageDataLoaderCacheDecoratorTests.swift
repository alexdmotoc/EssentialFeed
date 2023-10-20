//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.load(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTests {
    
    func test_init_doesNotMessageDecoratee() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.requestedURLs.isEmpty)
    }
    
    func test_load_deliversDataOnSuccess() {
        let (sut, spy) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            spy.complete(data: imageData)
        })
    }
    
    func test_load_deliversErrorOnFailure() {
        let (sut, spy) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            spy.complete(error: anyNSError())
        })
    }
    
    func test_load_savesDataToCacheOnSuccess() {
        let cache = CacheSpy()
        let (sut, spy) = makeSUT(cache: cache)
        let imageData = anyData()
        let loadURL = anyURL()
        
        _ = sut.load(from: loadURL) { _ in }
        spy.complete(data: imageData)
        
        XCTAssertEqual(cache.messages, [.save(imageData, loadURL)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        cache: CacheSpy = .init(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoaderCacheDecorator,
        spy: FeedImageDataLoaderSpy
    ) {
        let spy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: spy, cache: cache)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: cache, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    private class CacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(Data, URL)
        }
        private(set) var messages: [Message] = []
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data, url))
        }
    }
}
