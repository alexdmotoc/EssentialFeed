//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 19.10.2023.
//

import Foundation
import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let stub: FeedLoader.Result
    
    init(stub: FeedLoader.Result) {
        self.stub = stub
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(stub)
    }
}
