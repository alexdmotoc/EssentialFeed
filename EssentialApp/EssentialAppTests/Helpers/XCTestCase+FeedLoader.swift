//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 19.10.2023.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTests: XCTestCase {}

extension FeedLoaderTests {
    func expect(
        _ sut: FeedLoader,
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
}
