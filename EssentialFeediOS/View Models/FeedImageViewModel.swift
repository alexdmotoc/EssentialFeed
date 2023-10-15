//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private let model: FeedItem
    private let loader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?
    
    var onIsLoading: Observer<Bool>?
    var onIsRetryLoadingHidden: Observer<Bool>?
    var onLoadedImage: Observer<Image>?
    
    var description: String? { model.description }
    var location: String? { model.location }
    
    init(model: FeedItem, loader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.loader = loader
        self.imageTransformer = imageTransformer
    }
    
    func loadImage() {
        onIsLoading?(true)
        onIsRetryLoadingHidden?(true)
        task = loader.load(from: model.imageURL) { [weak self] result in
            self?.handleLoadResult(result)
        }
    }
    
    func cancelLoadImage() {
        task?.cancel()
        task = nil
    }
    
    private func handleLoadResult(_ result: FeedImageDataLoader.Result) {
        task = nil
        onIsLoading?(false)
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onLoadedImage?(image)
        } else {
            onIsRetryLoadingHidden?(false)
        }
    }
}
