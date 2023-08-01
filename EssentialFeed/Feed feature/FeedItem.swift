//
//  FeedItem.swift
//  
//
//  Created by Alex Motoc on 31.07.2023.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, description, location, imageURL = "image"
    }
}
