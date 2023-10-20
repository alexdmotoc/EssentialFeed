//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 19.10.2023.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedItem], completion: @escaping (Error?) -> Void)
}
