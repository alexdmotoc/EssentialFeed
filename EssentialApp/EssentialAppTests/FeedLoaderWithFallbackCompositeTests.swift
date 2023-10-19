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
        
        let exp = expectation(description: "wait for load")
        
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, primaryFeed)
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversResultsFromFallabackOnPrimaryFailure() {
        let fallbackFeed = uniqueImageFeed().models
        let sut = makeSUT(primaryStub: .failure(anyNSError()), fallbackStub: .success(fallbackFeed))
        
        let exp = expectation(description: "wait for load")
        
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, fallbackFeed)
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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
