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

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedImageDataLoader {
        private var feedPublishers: [PassthroughSubject<Paginated<FeedItem>, Error>] = []
        private(set) var imageLoadRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []
        private(set) var cancelledImageLoad: [URL] = []
        var loadedImages: [URL] { imageLoadRequests.map { $0.url } }
        var feedLoadCount: Int { feedPublishers.count }
        
        // MARK: - FeedLoader
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedItem>, Error> {
            let subject = PassthroughSubject<Paginated<FeedItem>, Error>()
            feedPublishers.append(subject)
            return subject.eraseToAnyPublisher()
        }
        
        func completeFeedLoad(withFeed feed: [FeedItem] = [], at index: Int = 0) {
            feedPublishers[index].send(Paginated(items: feed))
        }
        
        func completeFeedLoadWithError(at index: Int = 0) {
            feedPublishers[index].send(completion: .failure(NSError(domain: "mock", code: 0)))
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
