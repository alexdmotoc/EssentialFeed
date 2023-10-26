//
//  FeedItemMapperTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 31.07.2023.
//

import XCTest
import EssentialFeed

final class FeedItemMapperTests: XCTestCase {
    
    func test_map_onNon200StatusCode_throwsError() throws {
        let statusCodes = [199, 201, 300, 400, 500]
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "some desc", location: "some location", imageURL: URL(string: "https://a-url2.com")!)
        let json = makeItemsJSON([item1.json, item2.json])
        
        try statusCodes.forEach { code in
            XCTAssertThrowsError(
                try FeedItemMapper.map(response: HTTPURLResponse(statusCode: code), data: json)
            )
        }
    }
    
    func test_map_on200StatusCode_throwsErrorForInvalidJSONData() {
        let invalidJSON = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemMapper.map(response: HTTPURLResponse(statusCode: 200), data: invalidJSON)
        )
    }
    
    func test_map_on200StatusCode_returnsEmptyArrayForEmptyValidJSONData() throws {
        let emptyJSON = Data(#"{ "items": [] }"#.utf8)
        
        let results = try FeedItemMapper.map(response: HTTPURLResponse(statusCode: 200), data: emptyJSON)
        
        XCTAssertEqual(results, [])
    }
    
    func test_map_on200StatusCode_returnsArrayOfItemsForNonEmptyValidJSONData() throws {
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "some desc", location: "some location", imageURL: URL(string: "https://a-url2.com")!)
        let json = makeItemsJSON([item1.json, item2.json])
        
        let results = try FeedItemMapper.map(response: HTTPURLResponse(statusCode: 200), data: json)
        
        XCTAssertEqual(results, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
    
    private func makeItem(
        id: UUID,
        description: String?,
        location: String?,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: String]) {
        let model = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (model, json)
    }
}
