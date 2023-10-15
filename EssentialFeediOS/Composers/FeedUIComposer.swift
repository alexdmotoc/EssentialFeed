//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed

public enum FeedUIComposer {
    public static func makeFeedController(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedPresenter = FeedPresenter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: feedPresenter)
        let feedController = FeedViewController(refreshController: refreshController)
        let feedItemAdapter = FeedItemAdapter(controller: feedController, imageLoader: imageLoader)
        feedPresenter.feedLoadingView = refreshController
        feedPresenter.feedView = feedItemAdapter
        return feedController
    }
}

private final class FeedItemAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedItem]) {
        controller?.models = feed.map {
            FeedCellController(
                viewModel: FeedImageViewModel(
                    model: $0,
                    loader: imageLoader,
                    imageTransformer: UIImage.init
                )
            )
        }
    }
}
