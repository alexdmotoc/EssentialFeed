//
//  FeedLoaderPresenterAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresenterAdapter: FeedViewControllerDelegate {
    private let loader: FeedLoader
    var presenter: FeedPresenter?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        loader.load { [weak self] result in
            switch result {
            case .success(let items):
                self?.presenter?.didEndLoading(with: items)
            case .failure(let error):
                self?.presenter?.didEndLoading(with: error)
            }
        }
    }
}
