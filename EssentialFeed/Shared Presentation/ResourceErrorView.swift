//
//  ResourceErrorView.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 26.10.2023.
//

import Foundation

public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        .init(message: nil)
    }
    
    public static func error(message: String) -> Self {
        .init(message: message)
    }
}
