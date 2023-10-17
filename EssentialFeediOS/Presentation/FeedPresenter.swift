//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    static var title: String {
        String(
            localized: "FEED_VIEW_TITLE",
            table: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "The title of the main screen"
        )
    }
    
    private static var loadError: String {
        String(
            localized: "FEED_LOAD_ERROR",
            table: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when loading fails"
        )
    }
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoading(with feed: [FeedItem]) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    func didEndLoading(with error: Error) {
        errorView.display(.error(message: FeedPresenter.loadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
