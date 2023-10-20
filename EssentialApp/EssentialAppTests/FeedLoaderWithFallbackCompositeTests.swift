//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialApp
import EssentialFeed

final class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTests {

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
    
    func test_load_deliversErrorOnPrimaryAndFallbackError() {
        let sut = makeSUT(primaryStub: .failure(anyNSError()), fallbackStub: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        primaryStub: FeedLoader.Result,
        fallbackStub: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoaderWithFallbackComposite {
        let primary = FeedLoaderStub(stub: primaryStub)
        let fallback = FeedLoaderStub(stub: fallbackStub)
        let sut = FeedLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        checkIsDeallocated(sut: primary, file: file, line: line)
        checkIsDeallocated(sut: fallback, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
}
