//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    
    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}

public extension FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        var receivedResult: InsertionResult!
        group.enter()
        insert(data, for: url) { result in
            receivedResult = result
            group.leave()
        }
        group.wait()
        return try receivedResult.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        var receivedResult: RetrievalResult!
        group.enter()
        retrieve(dataForURL: url) { result in
            receivedResult = result
            group.leave()
        }
        group.wait()
        return try receivedResult.get()
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
}
