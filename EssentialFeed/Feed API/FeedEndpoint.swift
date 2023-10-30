//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 28.10.2023.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedItem? = nil)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(item):
            let url = baseURL.appending(path: "/v1/feed")
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                item.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
            ].compactMap { $0 }
            return components!.url!
        }
    }
}
