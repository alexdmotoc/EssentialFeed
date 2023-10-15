//
//  FeedCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit

final class FeedCellController {
    
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> FeedItemCell {
        let cell = FeedItemCell()
        cell.descriptionLabel.text = viewModel.description
        cell.descriptionLabel.isHidden = viewModel.description == nil
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = viewModel.location == nil
        cell.onRetry = viewModel.loadImage
        
        viewModel.onIsLoading = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        viewModel.onLoadedImage = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onIsRetryLoadingHidden = { [weak cell] isRetryLoadingHidden in
            cell?.retryButton.isHidden = isRetryLoadingHidden
        }
        
        return cell
    }
    
    func loadImage() {
        viewModel.loadImage()
    }
    
    func cancelLoad() {
        viewModel.cancelLoadImage()
    }
}
