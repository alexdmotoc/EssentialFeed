//
//  FeedItemCell.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 12.10.2023.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    @IBOutlet private(set) public weak var descriptionLabel: UILabel!
    @IBOutlet private(set) public weak var locationLabel: UILabel!
    @IBOutlet private(set) public weak var locationContainer: UIView!
    @IBOutlet private(set) public weak var feedImageContainer: UIView!
    @IBOutlet private(set) public weak var feedImageView: UIImageView!
    @IBOutlet private(set) public weak var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func didTapRetry() {
        onRetry?()
    }
}
