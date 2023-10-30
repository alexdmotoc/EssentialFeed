//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 30.10.2023.
//

import Foundation

public struct Paginated<Item> {
    public typealias LoadMore = (Result<Self, Error>) -> Void
    
    public let items: [Item]
    public let loadMore: LoadMore?
    
    public init(items: [Item], loadMore: LoadMore? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
