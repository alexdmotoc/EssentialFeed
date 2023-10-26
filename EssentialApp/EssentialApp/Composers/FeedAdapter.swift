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
    
    private typealias FeedItemPresentationAdapter = ResourceLoaderPresenterAdapter<Data, WeakRefVirtualProxy<FeedCellController>>
    
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedItemPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.imageURL)
            })
            let view = FeedCellController(
                delegate: adapter,
                viewModel: .init(
                    description: model.description,
                    location: model.location
                )
            )
            adapter.presenter = .init(
                loadingView: WeakRefVirtualProxy(view),
                resourceView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: Data.tryMap
            )
            return view
        })
    }
}

private extension Data {
    struct ImageDataMappingError: Error {}
    
    static func tryMap(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ImageDataMappingError()
        }
        return image
    }
}
