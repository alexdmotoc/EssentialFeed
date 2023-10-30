//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 28.10.2023.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appending(path: "/v1/feed")
        }
    }
}
