//
//  LocalFeedImageDataLoaderTests+Save.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoaderTests_Load: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_load_sendsLoadMessageToStore() {
        let (sut, store) = makeSUT()
        let someURL = anyURL()
        
        _ = sut.load(from: someURL) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(url: someURL)])
    }
    
    func test_load_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toLoadWith: loaderError(.failed), when: {
            store.completeRetrieval(error: anyNSError())
        })
    }
    
    func test_load_failsWithNotFoundErrorOnStoreNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toLoadWith: loaderError(.notFound), when: {
            store.completeRetrievalSuccessfully(data: .none)
        })
    }
    
    func test_load_deliversFoundDataOnStoreFoundData() {
        let (sut, store) = makeSUT()
        let someData = anyData()
        
        expect(sut, toLoadWith: .success(someData), when: {
            store.completeRetrievalSuccessfully(data: someData)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        checkIsDeallocated(sut: store, file: file, line:  line)
        checkIsDeallocated(sut: sut, file: file, line:  line)
        return (sut, store)
    }
    
    private func loaderError(_ error: LocalFeedImageDataLoader.LoadError) -> LocalFeedImageDataLoader.LoadResult {
        .failure(error)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toLoadWith expectedResult: LocalFeedImageDataLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        let exp = expectation(description: "wait for load")
        _ = sut.load(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            case (.failure(let expectedError as LocalFeedImageDataLoader.LoadError), .failure(let receivedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            case (.failure(let expectedError as NSError), .failure(let receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
