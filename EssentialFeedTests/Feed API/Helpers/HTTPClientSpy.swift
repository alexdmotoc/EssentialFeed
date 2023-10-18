//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    
    private struct TaskWrapper: HTTPClientTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    private(set) var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
    private(set) var cancelledURLs: [URL] = []
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    
    
    @discardableResult
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((url, completion))
        return TaskWrapper { [weak self] in self?.cancelledURLs.append(url) }
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
