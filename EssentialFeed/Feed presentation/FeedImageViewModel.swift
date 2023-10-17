//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let isRetryHidden: Bool
    
    public init(
        description: String?,
        location: String?,
        image: Image?,
        isLoading: Bool,
        isRetryHidden: Bool
    ) {
        self.description = description
        self.location = location
        self.image = image
        self.isLoading = isLoading
        self.isRetryHidden = isRetryHidden
    }
}
