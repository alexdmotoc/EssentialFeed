//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 18.10.2023.
//

import Foundation

public class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
        }
    }
    
    public func load(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        return task
    }
}