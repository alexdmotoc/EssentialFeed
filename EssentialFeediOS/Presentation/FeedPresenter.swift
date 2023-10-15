//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedItem]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let loader: FeedLoader
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func load() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: items))
            }
            self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
