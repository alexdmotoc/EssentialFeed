//
//  CommentsUIComposer.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import Combine

enum CommentsUIComposer {
    
    private typealias CommentsLoaderPresenterAdapter = ResourceLoaderPresenterAdapter<[ImageComment], CommentsAdapter>
    
    static func makeCommentsController(
        with commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        
        let commentsLoaderAdapter = CommentsLoaderPresenterAdapter(loader: commentsLoader)
        let controller = ListViewController.makeWith(title: ImageCommentsPresenter.title)
        controller.onRefresh = commentsLoaderAdapter.load
        
        commentsLoaderAdapter.presenter = ResourcePresenter(
            loadingView: WeakRefVirtualProxy(controller),
            resourceView: CommentsAdapter(controller: controller),
            errorView: WeakRefVirtualProxy(controller),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        return controller
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class CommentsAdapter: ResourceView {
    
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, dataSource: ImageCommentCellController(model: viewModel))
        })
    }
}
