//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 19.10.2023.
//

import XCTest
import EssentialApp
import EssentialFeed

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
    
    func test_load_deliversPrimaryDataOnPrimarySuccess() {
        let (sut, primary, _) = makeSUT()
        let someData = anyData()
        
        expect(sut, toCompleteWith: .success(someData), when: {
            primary.complete(data: someData)
        })
    }
    
    func test_load_deliversFallbackDataOnPrimaryError() {
        let (sut, primary, fallback) = makeSUT()
        let someData = anyData()
        
        expect(sut, toCompleteWith: .success(someData), when: {
            primary.complete(error: anyNSError())
            fallback.complete(data: someData)
        })
    }
    
    func test_load_deliversErrorOnPrimaryAndFallbackError() {
        let (sut, primary, fallback) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            primary.complete(error: anyNSError())
            fallback.complete(error: anyNSError())
        })
    }
    
    func test_cancelLoad_cancelsOnPrimary() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.load(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [url])
        XCTAssertEqual(fallback.cancelledURLs, [])
    }
    
    func test_cancelLoad_cancelsOnFallback() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.load(from: url) { _ in }
        primary.complete(error: anyNSError())
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [])
        XCTAssertEqual(fallback.cancelledURLs, [url])
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
    
    private func expect(
        _ sut: FeedImageDataLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load")
        
        _ = sut.load(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedData), .success(let expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
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
        
        func complete(data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
}
