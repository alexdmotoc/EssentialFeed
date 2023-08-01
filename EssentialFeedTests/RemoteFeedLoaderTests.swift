//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 31.07.2023.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestOnClient() {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsOnClient() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsOnClientTwice() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_onFailure_returnsErrorInCompletion() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { capturedErrors.append($0) }
        client.complete(with: NSError(domain: "An error", code: 0))
        
        XCTAssertEqual(client.requestedURLs, [url])
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_onNon200StatusCode_returnsErrorInCompletion() {
        let url = URL(string: "https://google.com")!
        let (client, sut) = makeSUT(url: url)
        
        let statusCodes = [199, 201, 300, 400, 500]
        
        statusCodes.enumerated().forEach { index, code in
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load { capturedErrors.append($0) }
            client.complete(with: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidResponse])
        }
        
        XCTAssertEqual(client.requestedURLs, statusCodes.map { _ in url })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-site.com")!) -> (client: HTTPClientSpy, loader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        return (client, RemoteFeedLoader(client: client, url: url))
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with status: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(response))
        }
    }
}
