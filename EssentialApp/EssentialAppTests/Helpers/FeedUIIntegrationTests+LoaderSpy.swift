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
    class LoaderSpy {
        private var feedPublishers: [PassthroughSubject<Paginated<FeedItem>, Error>] = []
        private var loadMorePublishers: [PassthroughSubject<Paginated<FeedItem>, Error>] = []
        private var imageLoadPublishers: [(url: URL, publisher: PassthroughSubject<Data, Error>)] = []
        
        private(set) var cancelledImageLoad: [URL] = []
        var loadedImages: [URL] { imageLoadPublishers.map { $0.url } }
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
        
        func imageLoadPublisher(at url: URL) -> AnyPublisher<Data, Error> {
            let subject = PassthroughSubject<Data, Error>()
            imageLoadPublishers.append((url, subject))
            return subject.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageLoad.append(url)
            }).eraseToAnyPublisher()
        }
        
        func completeImageLoad(withData data: Data = .init(), at index: Int = 0) {
            imageLoadPublishers[index].publisher.send(data)
            imageLoadPublishers[index].publisher.send(completion: .finished)
        }
        
        func completeImageLoadWithError(at index: Int = 0) {
            imageLoadPublishers[index].publisher.send(completion: .failure(NSError(domain: "mock", code: 0)))
        }
    }
}
