//
//  FeedItemCell.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 12.10.2023.
//

import UIKit

public final class FeedItemCell: UITableViewCell {
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let locationContainer = UIView()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(self.didTapRetry), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func didTapRetry() {
        onRetry?()
    }
}
