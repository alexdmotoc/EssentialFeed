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
            let url = baseURL.appending(path: "/v1/feed")
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            return components!.url!
        }
    }
}
