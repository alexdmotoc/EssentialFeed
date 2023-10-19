//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success(let items):
                completion(.success(items))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversResultsFromPrimaryOnSuccess() {
        let primaryFeed = uniqueImageFeed().models
        let sut = makeSUT(primaryStub: .success(primaryFeed), fallbackStub: .success(uniqueImageFeed().models))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_load_deliversResultsFromFallabackOnPrimaryFailure() {
        let fallbackFeed = uniqueImageFeed().models
        let sut = makeSUT(primaryStub: .failure(anyNSError()), fallbackStub: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryStub: FeedLoader.Result,
        fallbackStub: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderWithFallbackComposite {
        let primary = LoaderStub(stub: primaryStub)
        let fallback = LoaderStub(stub: fallbackStub)
        let sut = FeedLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        checkIsDeallocated(sut: primary, file: file, line: line)
        checkIsDeallocated(sut: fallback, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    private func expect(
        _ sut: FeedLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItems), .success(let expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private class LoaderStub: FeedLoader {
        private let stub: FeedLoader.Result
        
        init(stub: FeedLoader.Result) {
            self.stub = stub
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(stub)
        }
    }
}
