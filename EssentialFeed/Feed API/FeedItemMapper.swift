//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

enum FeedItemMapper {
    
    static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidResponse }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map(\.item)
    }
    
    private struct Root: Decodable {
        let items: [APIFeedItem]
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
