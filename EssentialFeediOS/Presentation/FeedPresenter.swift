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
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func didStartLoading() {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoading(with feed: [FeedItem]) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    func didEndLoading(with error: Error) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
