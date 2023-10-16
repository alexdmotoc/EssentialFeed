//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        private(set) var feedCompletions: [(FeedLoader.Result) -> Void] = []
        private(set) var imageLoadRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        private(set) var cancelledImageLoad: [URL] = []
        var loadedImages: [URL] { imageLoadRequests.map { $0.url } }
        var feedLoadCount: Int { feedCompletions.count }
        
        // MARK: - FeedLoader
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedCompletions.append(completion)
        }
        
        func completeFeedLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            feedCompletions[index](.success(feed))
        }
        
        func completeFeedLoadWithError(at index: Int = 0) {
            feedCompletions[index](.failure(NSError(domain: "mock", code: 0)))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
            let cancelHandler: () -> Void
            func cancel() {
                cancelHandler()
            }
        }
        
        func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageLoadRequests.append((url, completion))
            return FeedImageDataLoaderTaskSpy { [weak self] in self?.cancelledImageLoad.append(url) }
        }
        
        func completeImageLoad(withData data: Data = .init(), at index: Int = 0) {
            imageLoadRequests[index].completion(.success(data))
        }
        
        func completeImageLoadWithError(at index: Int = 0) {
            imageLoadRequests[index].completion(.failure(NSError(domain: "mock", code: 0)))
        }
    }
}
