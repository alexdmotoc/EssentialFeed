//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine
@testable import EssentialApp

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedImageDataLoader {
        private var feedPublishers: [PassthroughSubject<Paginated<FeedItem>, Error>] = []
        private var loadMorePublishers: [PassthroughSubject<Paginated<FeedItem>, Error>] = []
        
        private(set) var imageLoadRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        private(set) var cancelledImageLoad: [URL] = []
        var loadedImages: [URL] { imageLoadRequests.map { $0.url } }
        var feedLoadCount: Int { feedPublishers.count }
        var feedLoadMoreCount: Int { loadMorePublishers.count }
        
        // MARK: - FeedLoader
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedItem>, Error> {
            let subject = PassthroughSubject<Paginated<FeedItem>, Error>()
            feedPublishers.append(subject)
            return subject.eraseToAnyPublisher()
        }
        
        func completeFeedLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            feedPublishers[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
            feedPublishers[index].send(completion: .finished)
        }
        
        func completeFeedLoadWithError(at index: Int = 0) {
            feedPublishers[index].send(completion: .failure(NSError(domain: "mock", code: 0)))
        }
        
        // MARK: - Load more
        
        func loadMorePublisher() -> AnyPublisher<Paginated<FeedItem>, Error> {
            let subject = PassthroughSubject<Paginated<FeedItem>, Error>()
            loadMorePublishers.append(subject)
            return subject.eraseToAnyPublisher()
        }
        
        func completeLoadMore(with feed: [FeedItem] = [], lastPage: Bool = false, at index: Int = 0) {
            loadMorePublishers[index].send(
                Paginated(items: feed, loadMorePublisher: lastPage ? nil : { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                })
            )
            loadMorePublishers[index].send(completion: .finished)
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            loadMorePublishers[index].send(completion: .failure(NSError(domain: "mock", code: 0)))
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
