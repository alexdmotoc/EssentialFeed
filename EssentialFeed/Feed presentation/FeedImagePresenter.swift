//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didDequeueCell(for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                isRetryHidden: true
            )
        )
    }
    
    public func didStartLoadingImage(for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                isRetryHidden: true
            )
        )
    }
    
    public func didEndLoadingImage(with error: Error, for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                isRetryHidden: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didEndLoadingImage(with data: Data, for model: FeedItem) {
        guard let image = imageTransformer(data) else {
            didEndLoadingImage(with: InvalidImageDataError(), for: model)
            return
        }
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                isRetryHidden: true
            )
        )
    }
}
