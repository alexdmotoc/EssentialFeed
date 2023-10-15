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
        let feedPresenter = FeedPresenter()
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader, presenter: feedPresenter)
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        let feedItemAdapter = FeedItemAdapter(controller: feedController, imageLoader: imageLoader)
        feedPresenter.feedLoadingView = WeakRefVirtualProxy(object: refreshController)
        feedPresenter.feedView = feedItemAdapter
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedLoaderPresenterAdapter: FeedRefreshViewControllerDelegate {
    private let loader: FeedLoader
    private let presenter: FeedPresenter
    
    init(loader: FeedLoader, presenter: FeedPresenter) {
        self.loader = loader
        self.presenter = presenter
    }
    
    func didRequestFeedRefresh() {
        presenter.didStartLoading()
        loader.load { [weak self] result in
            switch result {
            case .success(let items):
                self?.presenter.didEndLoading(with: items)
            case .failure(let error):
                self?.presenter.didEndLoading(with: error)
            }
        }
    }
}

private final class FeedItemAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.models = viewModel.feed.map {
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
