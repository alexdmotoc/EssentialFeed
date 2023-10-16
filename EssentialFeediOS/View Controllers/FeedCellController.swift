//
//  FeedCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit

protocol FeedCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
    func didDequeueCell()
}

final class FeedCellController: FeedImageView {
    
    private let delegate: FeedCellControllerDelegate
    private var cell: FeedItemCell?
    
    init(delegate: FeedCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> FeedItemCell {
        cell = tableView.dequeueCell()
        delegate.didDequeueCell()
        return cell!
    }
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.descriptionLabel.text = viewModel.description
        cell?.descriptionLabel.isHidden = viewModel.description == nil
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = viewModel.location == nil
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.retryButton.isHidden = viewModel.isRetryHidden
        cell?.onRetry = { [weak self] in self?.delegate.didRequestImage() }
        cell?.onPrepareForReuse = { [weak self] in self?.releaseCellReference() }
        if viewModel.isLoading {
            cell?.feedImageContainer.startShimmering()
        } else {
            cell?.feedImageContainer.stopShimmering()
        }
    }
    
    func loadImage() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellReference()
    }
    
    private func releaseCellReference() {
        cell = nil
    }
}
