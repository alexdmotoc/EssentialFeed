//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, url: URL)
        case retrieve(url: URL)
    }
    
    private(set) var messages: [Message] = []
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<Data?, Error>?
    
    func insert(_ data: Data, for url: URL) throws -> Void {
        messages.append(.insert(data: data, url: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        messages.append(.retrieve(url: url))
        return try retrievalResult?.get()
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    func completeInsertion(error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeRetrievalSuccessfully(data: Data?) {
        retrievalResult = .success(data)
    }
    
    func completeRetrieval(error: Error) {
        retrievalResult = .failure(error)
    }
}
