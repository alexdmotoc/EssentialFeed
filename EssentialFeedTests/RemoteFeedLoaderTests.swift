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
        let (client, sut) = makeSUT()
        
        expect(sut: sut, completesWith: .failure(.connectivity), when: {
            client.complete(with: NSError(domain: "An error", code: 0))
        })
    }
    
    func test_load_onNon200StatusCode_returnsErrorInCompletion() {
        let (client, sut) = makeSUT()
        
        let statusCodes = [199, 201, 300, 400, 500]
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "some desc", location: "some location", imageURL: URL(string: "https://a-url2.com")!)
        let json = makeJSONData(from: [item1.json, item2.json])
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut: sut, completesWith: .failure(.invalidResponse), when: {
                client.complete(with: code, data: json, at: index)
            })
        }
    }
    
    func test_load_on200StatusCode_returnsErrorForInvalidJSONData() {
        let (client, sut) = makeSUT()
        
        let invalidJSON = Data("invalid json".utf8)
        
        expect(sut: sut, completesWith: .failure(.invalidResponse), when: {
            client.complete(with: 200, data: invalidJSON)
        })
    }
    
    func test_load_on200StatusCode_returnsEmptyArrayForEmptyValidJSONData() {
        let (client, sut) = makeSUT()
        
        let emptyJSON = Data(#"{ "items": [] }"#.utf8)
        
        expect(sut: sut, completesWith: .success([]), when: {
            client.complete(with: 200, data: emptyJSON)
        })
    }
    
    func test_load_on200StatusCode_returnsArrayOfItemsForNonEmptyValidJSONData() {
        let (client, sut) = makeSUT()
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "some desc", location: "some location", imageURL: URL(string: "https://a-url2.com")!)
        let json = makeJSONData(from: [item1.json, item2.json])
        
        expect(sut: sut, completesWith: .success([item1.model, item2.model]), when: {
            client.complete(with: 200, data: json)
        })
    }
    
    func test_load_doesntCallCompletionAfterBeingDeallocated() {
        let url = URL(string: "https://some-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(with: 200, data: makeJSONData(from: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-site.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (client: HTTPClientSpy, loader: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        
        return (client, sut)
    }
    
    private func checkIsDeallocated(
        sut: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, file: file, line: line)
        }
    }
    
    private func makeJSONData(from items: [[String: String]]) -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "items": items
        ])
    }
    
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
    
    private func expect(
        sut: RemoteFeedLoader,
        completesWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with status: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((response, data)))
        }
    }
}
