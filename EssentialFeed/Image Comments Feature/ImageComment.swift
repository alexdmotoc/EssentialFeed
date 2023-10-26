//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 26.10.2023.
//

import Foundation

public struct ImageComment {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let username: String
    
    public init(id: UUID, message: String, createdAt: Date, username: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.username = username
    }
}
