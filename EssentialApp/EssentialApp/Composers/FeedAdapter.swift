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
    private typealias LoadMorePresentationAdapter = ResourceLoaderPresenterAdapter<Paginated<FeedItem>, FeedAdapter>
    
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedItem) -> Void
    
    init(
        controller: ListViewController,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedItem) -> Void
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedItem>) {
        let feedSection: [CellController] = viewModel.items.map { model in
            let adapter = FeedItemPresentationAdapter(loader: { [imageLoader] in
                imageLoader(model.imageURL)
            })
            let view = FeedCellController(
                delegate: adapter,
                viewModel: .init(
                    description: model.description,
                    location: model.location
                ), 
                selection: { [selection] in selection(model) }
            )
            adapter.presenter = .init(
                loadingView: WeakRefVirtualProxy(view),
                resourceView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: Data.tryMap
            )
            return CellController(id: model, dataSource: view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher() else {
            controller?.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: { loadMorePublisher } )
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.load)
        
        loadMoreAdapter.presenter = ResourcePresenter(
            loadingView: WeakRefVirtualProxy(loadMore),
            resourceView: self,
            errorView: WeakRefVirtualProxy(loadMore)
        )
        
        let loadMoreSection = [CellController(id: UUID(), dataSource: loadMore)]
        controller?.display(feedSection, loadMoreSection)
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
