//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 31.07.2023.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotCallGetOnClient() {
        let (client, _) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_callsGetWithTheSpecifiedURLOnClient() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT()
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://google.com")!) -> (client: HTTPClientSpy, loader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        return (client, RemoteFeedLoader(client: client, url: url))
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        func get(url: URL) {
            requestedURL = url
        }
    }

}
