//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 19.10.2023.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.load(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                task.wrapped = self?.fallback.load(from: url, completion: completion)
            }
        }
        return task
    }
}

final class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotMessagePrimaryNorFallback() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.requestedURLs.isEmpty)
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
    func test_load_loadsFromPrimaryFirst() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(primary.requestedURLs, [url])
        XCTAssertTrue(fallback.requestedURLs.isEmpty)
    }
    
    func test_load_loadsFromFallbackOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        _ = sut.load(from: url) { _ in }
        primary.complete(error: anyNSError())
        
        XCTAssertEqual(primary.requestedURLs, [url])
        XCTAssertEqual(fallback.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: FeedImageDataLoaderWithFallbackComposite,
        primary: LoaderSpy,
        fallback: LoaderSpy
    ) {
        let primary = LoaderSpy()
        let fallback = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        checkIsDeallocated(sut: primary, file: file, line: line)
        checkIsDeallocated(sut: fallback, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, primary, fallback)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() {
                callback()
            }
        }
        
        private(set) var cancelledURLs: [URL] = []
        private var messages: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        var requestedURLs: [URL] { messages.map(\.url)}
        
        func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in self?.cancelledURLs.append(url) }
        }
        
        func complete(error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
