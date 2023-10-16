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
        let feedLoaderPresenterAdapter = FeedLoaderPresenterAdapter(loader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.refreshController = refreshController
        
        let feedItemAdapter = FeedItemAdapter(controller: feedController, imageLoader: imageLoader)
        feedLoaderPresenterAdapter.presenter = FeedPresenter(
            feedLoadingView: WeakRefVirtualProxy(refreshController),
            feedView: feedItemAdapter
        )
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T?) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel)
    }
}

private final class FeedLoaderPresenterAdapter: FeedRefreshViewControllerDelegate {
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

private final class FeedItemAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController?, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.models = viewModel.feed.map {
            let adapter = FeedItemPresentationAdapter<WeakRefVirtualProxy<FeedCellController>, UIImage>(
                model: $0,
                loader: imageLoader
            )
            let view = FeedCellController(delegate: adapter)
            adapter.presenter = .init(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
    }
}

private final class FeedItemPresentationAdapter<View: FeedImageView, Image>: FeedCellControllerDelegate where View.Image == Image {
    
    private let model: FeedItem
    private let loader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedItem, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        task = loader.load(from: model.imageURL) { [weak self, model] result in
            self?.task = nil
            switch result {
            case .success(let data):
                self?.presenter?.didEndLoadingImage(with: data, for: model)
            case .failure(let error):
                self?.presenter?.didEndLoadingImage(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
        task = nil
    }
    
    func didDequeueCell() {
        presenter?.didDequeueCell(for: model)
    }
}
