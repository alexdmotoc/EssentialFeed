//
//  FeedLoaderPresenterAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedLoaderPresenterAdapter: FeedViewControllerDelegate {
    private let loader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    init(loader: @escaping () -> FeedLoader.Publisher) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = loader().sink(
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
