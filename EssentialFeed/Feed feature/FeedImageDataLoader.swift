//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import Foundation

public protocol FeedImageDataLoader {
    func load(from url: URL) throws -> Data
}
