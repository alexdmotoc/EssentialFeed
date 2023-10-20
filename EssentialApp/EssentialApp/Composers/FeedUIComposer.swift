//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public enum FeedUIComposer {
    public static func makeFeedController(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoaderAdapter = FeedLoaderPresenterAdapter(loader: MainQueueDispatchDecorator(feedLoader))
        
        let feedController = FeedViewController.makeWith(
            title: FeedPresenter.title,
            delegate: feedLoaderAdapter
        )
        
        let feedAdapter = FeedAdapter(
            controller: feedController,
            imageLoader: MainQueueDispatchDecorator(imageLoader)
        )
        
        feedLoaderAdapter.presenter = FeedPresenter(
            feedLoadingView: WeakRefVirtualProxy(feedController),
            feedView: feedAdapter, 
            errorView: WeakRefVirtualProxy(feedController)
        )
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(
        title: String,
        delegate: FeedViewControllerDelegate
    ) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
