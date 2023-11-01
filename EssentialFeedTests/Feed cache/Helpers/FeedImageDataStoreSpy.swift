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
    private var retrievalCompletions: [(RetrievalResult) -> Void] = []
    
    func insert(_ data: Data, for url: URL) throws -> Void {
        messages.append(.insert(data: data, url: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        messages.append(.retrieve(url: url))
        retrievalCompletions.append(completion)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    func completeInsertion(error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeRetrievalSuccessfully(data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
}
