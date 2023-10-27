//
//  FeedCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed

public protocol FeedCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedCellController: NSObject {
    private let delegate: FeedCellControllerDelegate
    private let viewModel: FeedImageViewModel
    private var cell: FeedItemCell?
    
    public init(delegate: FeedCellControllerDelegate, viewModel: FeedImageViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
}

// MARK: - Table View Conformance

extension FeedCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueCell()
        cell?.descriptionLabel.text = viewModel.description
        cell?.descriptionLabel.isHidden = viewModel.description == nil
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = viewModel.location == nil
        cell?.onRetry = { [weak self] in self?.delegate.didRequestImage() }
        cell?.onPrepareForReuse = { [weak self] in self?.releaseCellReference() }
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        preload(for: cell)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        preload()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoad()
    }
    
    private func preload(for cell: UITableViewCell? = nil) {
        captureCellReference(cell as? FeedItemCell)
        delegate.didRequestImage()
    }
    
    private func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellReference()
    }
    
    private func releaseCellReference() {
        cell = nil
    }
    
    private func captureCellReference(_ cell: FeedItemCell?) {
        if let cell { self.cell = cell }
    }
}

// MARK: - View conformance

extension FeedCellController: ResourceLoadingView, ResourceErrorView, ResourceView {
    public typealias ResourceViewModel = UIImage
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
    }
}
