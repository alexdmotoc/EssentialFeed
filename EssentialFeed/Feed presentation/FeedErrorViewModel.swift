//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        .init(message: nil)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        .init(message: message)
    }
}
