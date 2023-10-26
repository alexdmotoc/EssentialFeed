//
//  FeedAdapter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map {
            let adapter = FeedItemPresentationAdapter<WeakRefVirtualProxy<FeedCellController>, UIImage>(
                model: $0,
                loader: imageLoader
            )
            let view = FeedCellController(delegate: adapter)
            adapter.presenter = .init(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        })
    }
}
