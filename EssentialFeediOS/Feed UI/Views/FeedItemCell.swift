//
//  FeedItemCell.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 12.10.2023.
//

import UIKit

final class FeedItemCell: UITableViewCell {
    @IBOutlet private(set) weak var descriptionLabel: UILabel!
    @IBOutlet private(set) weak var locationLabel: UILabel!
    @IBOutlet private(set) weak var locationContainer: UIView!
    @IBOutlet private(set) weak var feedImageContainer: UIView!
    @IBOutlet private(set) weak var feedImageView: UIImageView!
    @IBOutlet private(set) weak var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    var onPrepareForReuse: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onPrepareForReuse?()
    }
    
    @IBAction private func didTapRetry() {
        onRetry?()
    }
}
