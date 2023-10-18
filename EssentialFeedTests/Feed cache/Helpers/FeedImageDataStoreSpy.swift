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
    private var insertionCompletions: [(InsertionResult) -> Void] = []
    private var retrievalCompletions: [(RetrievalResult) -> Void] = []
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        messages.append(.insert(data: data, url: url))
        insertionCompletions.append(completion)
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {
        messages.append(.retrieve(url: url))
        retrievalCompletions.append(completion)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completeInsertion(error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetrievalSuccessfully(data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeRetrieval(error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
}
