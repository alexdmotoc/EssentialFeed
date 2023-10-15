//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func initialCellDisplay(for model: FeedItem) {
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
    
    func didStartLoadingImage(for model: FeedItem) {
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
    
    private struct InvalidImageDataError: Error {}
    
    func didEndLoadingImage(with data: Data, for model: FeedItem) {
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
    
    func didEndLoadingImage(with error: Error, for model: FeedItem) {
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
}
