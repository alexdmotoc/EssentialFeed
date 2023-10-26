//
//  SharedTestUtils.swift
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
}

func uniqueImage() -> FeedItem {
    FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "some-url.com")!)
}

func uniqueImageFeed() -> (local: [LocalFeedImage], models: [FeedItem]) {
    let items = [
        uniqueImage(),
        uniqueImage(),
        uniqueImage()
    ]
    let local = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    return (local, items)
}

func anyNSError() -> NSError {
    NSError(domain: "com.tests.mockError", code: 0)
}

func anyURL() -> URL {
    .init(string: "https://some-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    try! JSONSerialization.data(withJSONObject: [
        "items": items
    ])
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }

    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}
