//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

enum FeedUIComposer {
    
    private typealias FeedLoaderPresenterAdapter = ResourceLoaderPresenterAdapter<[FeedItem], FeedAdapter>
    
    static func makeFeedController(
        with feedLoader: @escaping () -> AnyPublisher<[FeedItem], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        
        let feedLoaderAdapter = FeedLoaderPresenterAdapter(loader: feedLoader)
        let feedController = FeedViewController.makeWith(title: FeedPresenter.title)
        feedController.onRefresh = feedLoaderAdapter.load
        
        let feedAdapter = FeedAdapter(
            controller: feedController,
            imageLoader: { url in
                imageLoader(url).dispatchOnMainQueue()
            }
        )
        
        feedLoaderAdapter.presenter = ResourcePresenter<[FeedItem], FeedAdapter>(
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: feedAdapter,
            errorView: WeakRefVirtualProxy(feedController), 
            mapper: FeedPresenter.map
        )
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.title = title
        return feedController
    }
}
