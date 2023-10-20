//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() {
            callback()
        }
    }
    
    private(set) var cancelledURLs: [URL] = []
    private var messages: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
    var requestedURLs: [URL] { messages.map(\.url)}
    
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in self?.cancelledURLs.append(url) }
    }
    
    func complete(error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
