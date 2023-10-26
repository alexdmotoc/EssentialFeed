//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public init(description: String?, location: String?) {
        self.description = description
        self.location = location
    }
}
