//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func load(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
