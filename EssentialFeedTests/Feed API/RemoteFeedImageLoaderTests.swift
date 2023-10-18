//
//  RemoteFeedImageLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private struct HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private let wrapped: HTTPClientTask
        
        init(_ wrapped: HTTPClientTask) {
            self.wrapped = wrapped
        }
        
        func cancel() {}
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = client.get(url: url) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return HTTPClientTaskWrapper(task)
    }
}

final class RemoteFeedImageLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_getData_requestsDataFromClient() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_getDataTwice_requestsDataFromClientTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        _ = sut.load(from: url) { _ in }
        _ = sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_getData_returnsErrorOnClientError() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "wait for request to complete")
        let clientError = anyNSError()
        
        _ = sut.load(from: anyURL()) { result in
            switch result {
            case .success:
                XCTFail("Expected to complete with error got success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, clientError)
            }
            exp.fulfill()
        }
        
        client.complete(with: clientError)
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, client)
    }
}
