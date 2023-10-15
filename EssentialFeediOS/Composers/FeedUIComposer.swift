//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import EssentialFeed

public enum FeedUIComposer {
    public static func makeFeedController(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(loader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedStateChange = adaptFeedToCellControllers(forwardingTo: feedController, imageLoader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        imageLoader: FeedImageDataLoader
    ) -> ([FeedItem]) -> Void {
        { [weak controller] items in
            controller?.models = items.map { FeedCellController(model: $0, loader: imageLoader) }
        }
    }
}
