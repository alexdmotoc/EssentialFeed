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
    private var isLoading = false
    
    var presenter: ResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func load() {
        guard !isLoading else { return }
        
        isLoading = true
        
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.presenter?.didEndLoading(with: failure)
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] items in
                self?.presenter?.didEndLoading(with: items)
            })
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
