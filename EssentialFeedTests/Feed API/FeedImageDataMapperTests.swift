//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200StatusCode() throws {
        let statusCodes = [199, 201, 300, 400, 500]
        
        try statusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(response: HTTPURLResponse(statusCode: statusCode), data: anyData())
            )
        }
    }
    
    func test_map_throwsErrorOnEmptyDataAnd200StatusCode() {
        XCTAssertThrowsError(
            try FeedImageDataMapper.map(response: HTTPURLResponse(statusCode: 200), data: Data())
        )
    }
    
    func test_map_returnsDataOnNonEmptyDataAnd200StatusCode() throws {
        let someData = anyData()
        
        let receivedData = try FeedImageDataMapper.map(response: HTTPURLResponse(statusCode: 200), data: someData)
        
        XCTAssertEqual(receivedData, someData)
    }
}
