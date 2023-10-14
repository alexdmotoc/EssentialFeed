//
//  FeedCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed

final class FeedCellController {
    
    private let model: FeedItem
    private let loader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedItem, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }
    
    func view() -> FeedItemCell {
        let cell = FeedItemCell()
        cell.descriptionLabel.text = model.description
        cell.descriptionLabel.isHidden = model.description == nil
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.onRetry = { [weak self, weak cell] in
            guard let cell else { return }
            self?.loadImage(forCell: cell)
        }
        return cell
    }
    
    func loadImage(forCell cell: FeedItemCell?) {
        cell?.retryButton.isHidden = true
        cell?.feedImageContainer.startShimmering()
        task = loader.load(from: model.imageURL) { [weak self, weak cell] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            cell?.retryButton.isHidden = image != nil
            cell?.feedImageView.image = image
            cell?.feedImageContainer.stopShimmering()
            self?.task = nil
        }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
