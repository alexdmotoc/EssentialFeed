//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let isRetryHidden: Bool
}
