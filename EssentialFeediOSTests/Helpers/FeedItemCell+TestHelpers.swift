//
//  FeedItemCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeediOS

extension FeedItemCell {
    var descriptionText: String? { descriptionLabel.text }
    var isDescriptionHidden: Bool { descriptionLabel.isHidden }
    var locationText: String? { locationLabel.text }
    var isLocationHidden: Bool { locationContainer.isHidden }
    var isShowingLoadingIndicator: Bool { feedImageContainer.isShimmering }
    var renderedImageData: Data? { feedImageView.image?.pngData() }
    var isRetryButtonHidden: Bool { retryButton.isHidden }
    
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}
