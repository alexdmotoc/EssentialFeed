//
//  FeedItemPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

final class FeedItemPresentationAdapter<View: FeedImageView, Image>: FeedCellControllerDelegate where View.Image == Image {
    
    private let model: FeedItem
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedItem, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.loader = loader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImage(for: model)
        cancellable = loader(model.imageURL).sink(
            receiveCompletion: { [weak self, model] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    self?.presenter?.didEndLoadingImage(with: failure, for: model)
                }
            },
            receiveValue: { [weak self, model] data in
                self?.presenter?.didEndLoadingImage(with: data, for: model)
            }
        )
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
    
    func didDequeueCell() {
        presenter?.didDequeueCell(for: model)
    }
}
