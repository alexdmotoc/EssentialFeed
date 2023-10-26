//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public enum FeedItemMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.feed
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
