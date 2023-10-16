//
//  FeedAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import UIKit

final class FeedAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
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
