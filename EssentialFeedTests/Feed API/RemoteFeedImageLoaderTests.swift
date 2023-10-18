//
//  RemoteFeedImageLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrapped = client.get(url: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (response, data) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
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
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
    
    func test_getData_returnsErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(with: statusCode, data: anyData(), at: index)
            })
        }
    }
    
    func test_getData_returnsErrorOnEmptyDataAnd200StatusCode() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(with: 200, data: Data())
        })
    }
    
    func test_getData_returnsDataOnNonEmptyDataAnd200StatusCode() {
        let (sut, client) = makeSUT()
        let someData = anyData()
        
        expect(sut, toCompleteWith: .success(someData), when: {
            client.complete(with: 200, data: someData)
        })
    }
    
    func test_cancelLoad_cancelsOnClient() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.load(from: url) { _ in }
        XCTAssertEqual(client.cancelledURLs, [])
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    func test_getData_doesNotCompleteAfterTaskHasBeenCancelled() {
        let (sut, client) = makeSUT()
        var receivedCompletions: [FeedImageDataLoader.Result] = []
        
        let task = sut.load(from: anyURL()) { receivedCompletions.append($0) }
        task.cancel()
        
        client.complete(with: anyNSError())
        client.complete(with: 199, data: anyData())
        client.complete(with: 200, data: Data())
        client.complete(with: 200, data: anyData())
        
        XCTAssertTrue(receivedCompletions.isEmpty)
    }
    
    func test_getData_doesNotCompleteAfterSUTHasBeedDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        var receivedCompletions: [FeedImageDataLoader.Result] = []
        
        _ = sut?.load(from: anyURL()) { receivedCompletions.append($0) }
        sut = nil
        client.complete(with: 200, data: anyData())
        
        XCTAssertTrue(receivedCompletions.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkIsDeallocated(sut: client, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for request to complete")
        _ = sut.load(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedData), .success(let expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure(let receivedError as RemoteFeedImageDataLoader.Error), .failure(let expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected to receive \(expectedResult), received \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
}
