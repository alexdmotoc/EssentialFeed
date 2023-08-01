//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

enum FeedItemMapper {
    
    static func map(response: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidResponse)
        }
        return .success(root.feed)
    }
    
    private struct Root: Decodable {
        let items: [APIFeedItem]
        var feed: [FeedItem] {
            items.map(\.item)
        }
    }

    private struct APIFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            .init(id: id, description: description, location: location, imageURL: image)
        }
    }
}
