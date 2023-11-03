//
//  LocalFeedImageDataLoaderTests+Save.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class LocalFeedImageDataLoaderTests_Save: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_sendsSaveMessageToStore() throws {
        let (sut, store) = makeSUT()
        let someData = anyData()
        let someURL = anyURL()
        
        try sut.save(someData, for: someURL)
        
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
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        checkIsDeallocated(sut: store, file: file, line:  line)
        checkIsDeallocated(sut: sut, file: file, line:  line)
        return (sut, store)
    }
    
    private func failed() -> Result<Void, Error> {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toSaveWith expectedResult: Result<Void, Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        action()
        let receivedResult = Result { try sut.save(anyData(), for: anyURL()) }
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
    }
}
