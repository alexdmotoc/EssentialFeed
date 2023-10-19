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
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {

    func test_load_deliversResultsFromPrimaryOnSuccess() {
        let primaryFeed = uniqueFeed
        let fallbackFeed = uniqueFeed
        let primary = LoaderStub(stub: .success(primaryFeed))
        let fallback = LoaderStub(stub: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        
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
    
    // MARK: - Helpers
    
    private var uniqueFeed: [FeedItem] {
        [
            FeedItem(id: UUID(), description: "some desc", location: "some loc", imageURL: URL(string: "some-url.com")!)
        ]
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
