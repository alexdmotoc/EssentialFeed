//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 20.10.2023.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
