//
//  ResourceLoadingView.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 26.10.2023.
//

import Foundation

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}
