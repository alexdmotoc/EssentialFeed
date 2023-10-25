//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(closure: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: closure)
        }
        closure()
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func load(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
