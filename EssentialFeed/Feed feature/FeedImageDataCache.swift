//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 20.10.2023.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
