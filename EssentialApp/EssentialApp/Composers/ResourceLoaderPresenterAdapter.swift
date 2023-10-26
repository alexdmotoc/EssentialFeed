//
//  ResourceLoaderPresenterAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class ResourceLoaderPresenterAdapter<Resource, View: ResourceView> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: ResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func load() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.presenter?.didEndLoading(with: failure)
                }
            },
            receiveValue: { [weak self] items in
                self?.presenter?.didEndLoading(with: items)
            }
        )
    }
}

extension ResourceLoaderPresenterAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        load()
    }
}

extension ResourceLoaderPresenterAdapter: FeedCellControllerDelegate {
    func didRequestImage() {
        load()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
