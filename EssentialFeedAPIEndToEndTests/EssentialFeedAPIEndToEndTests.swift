//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Alex Motoc on 02.08.2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_getFromURL_retrievesDataFromServer() {
        switch getResult() {
        case .none:
            XCTFail("Expected to receive items, got nothing")
        case .failure(let error):
            XCTFail("Expected to receive items, got error: \(error)")
        case .success(let items):
            XCTAssertEqual(items.count, 8)
            XCTAssertEqual(items[0], getItem(at: 0))
            XCTAssertEqual(items[1], getItem(at: 1))
            XCTAssertEqual(items[2], getItem(at: 2))
            XCTAssertEqual(items[3], getItem(at: 3))
            XCTAssertEqual(items[4], getItem(at: 4))
            XCTAssertEqual(items[5], getItem(at: 5))
            XCTAssertEqual(items[6], getItem(at: 6))
            XCTAssertEqual(items[7], getItem(at: 7))
        }
    }
    
    // MARK: - Helpers
    
    private func getResult() -> RemoteFeedLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let service = RemoteFeedLoader(client: client, url: testServerURL)
        
        var receivedResult: RemoteFeedLoader.Result?
        let exp = expectation(description: "wait for request to complete")
        
        service.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        
        return receivedResult
    }
    
    func getItem(at index: Int) -> FeedItem {
        .init(
            id: getID(at: index),
            description: getDescription(at: index),
            location: getLocation(at: index),
            imageURL: getImageURL(at: index)
        )
    }
    
    private func getID(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func getDescription(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func getLocation(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func getImageURL(at index: Int) -> URL {
        URL(string: "https://url-\(index+1).com")!
    }
}
