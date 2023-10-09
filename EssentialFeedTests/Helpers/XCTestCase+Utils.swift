//
//  XCTestCase+Utils.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 02.08.2023.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func checkIsDeallocated(
        sut: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, file: file, line: line)
        }
    }
    
    func uniqueImageFeed() -> (local: [LocalFeedImage], models: [FeedItem]) {
        let items = [
            FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "some-url.com")!),
            FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "some-url.com")!),
            FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "some-url.com")!)
        ]
        let local = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
        return (local, items)
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "com.tests.mockError", code: 0)
    }
}
