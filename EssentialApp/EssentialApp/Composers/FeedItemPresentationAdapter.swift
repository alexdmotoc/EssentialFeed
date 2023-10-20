//
//  FeedItemPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import EssentialFeed
import EssentialFeediOS

final class FeedItemPresentationAdapter<View: FeedImageView, Image>: FeedCellControllerDelegate where View.Image == Image {
    
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
