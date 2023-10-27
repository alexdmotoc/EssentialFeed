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

public final class FeedCellController: CellController, ResourceLoadingView, ResourceErrorView, ResourceView {
    public typealias ResourceViewModel = UIImage
    
    private let delegate: FeedCellControllerDelegate
    private let viewModel: FeedImageViewModel
    private var cell: FeedItemCell?
    
    public init(delegate: FeedCellControllerDelegate, viewModel: FeedImageViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueCell()
        cell?.descriptionLabel.text = viewModel.description
        cell?.descriptionLabel.isHidden = viewModel.description == nil
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = viewModel.location == nil
        cell?.onRetry = { [weak self] in self?.delegate.didRequestImage() }
        cell?.onPrepareForReuse = { [weak self] in self?.releaseCellReference() }
        return cell!
    }
    
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
    
    public func preload(for cell: UITableViewCell? = nil) {
        captureCellReference(cell as? FeedItemCell)
        delegate.didRequestImage()
    }
    
    public func cancelLoad() {
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
