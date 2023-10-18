//
//  LocalFeedImageDataLoaderTests+Save.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_sendsSaveMessageToStore() {
        let (sut, store) = makeSUT()
        let someData = anyData()
        let someURL = anyURL()
        
        sut.save(someData, for: someURL) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(data: someData, url: someURL)])
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toSaveWith: failed(), when: {
            store.completeInsertion(error: anyNSError())
        })
    }
    
    func test_save_succeedsOnNoInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toSaveWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotCompleteAfterItWasDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var receivedResults: [LocalFeedImageDataLoader.SaveResult] = []
        sut?.save(anyData(), for: anyURL()) { receivedResults.append($0) }
        sut = nil
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        checkIsDeallocated(sut: store, file: file, line:  line)
        checkIsDeallocated(sut: sut, file: file, line:  line)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toSaveWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for save")
        sut.save(anyData(), for: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success, .success):
                break
            case (.failure(let expectedError as LocalFeedImageDataLoader.SaveError), .failure(let receivedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            case (.failure(let expectedError as NSError), .failure(let receivedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private class FeedImageDataStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case insert(data: Data, url: URL)
            case retrieve(url: URL)
        }
        
        private(set) var messages: [Message] = []
        private var insertionCompletions: [(InsertionResult) -> Void] = []
        private var retrievalCompletions: [(RetrievalResult) -> Void] = []
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            messages.append(.insert(data: data, url: url))
            insertionCompletions.append(completion)
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
            messages.append(.retrieve(url: url))
            retrievalCompletions.append(completion)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](.success(()))
        }
        
        func completeInsertion(error: Error, at index: Int = 0) {
            insertionCompletions[index](.failure(error))
        }
        
        func completeRetrievalSuccessfully(data: Data?, at index: Int = 0) {
            retrievalCompletions[index](.success(data))
        }
        
        func completeRetrieval(error: Error, at index: Int = 0) {
            retrievalCompletions[index](.failure(error))
        }
    }
}
