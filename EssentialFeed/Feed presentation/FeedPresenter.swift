//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public protocol FeedLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    public static var title: String {
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
    
    public init(feedLoadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    public func didStartLoading() {
        errorView.display(.noError)
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didEndLoading(with feed: [FeedItem]) {
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    public func didEndLoading(with error: Error) {
        errorView.display(.error(message: FeedPresenter.loadError))
        feedLoadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
