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

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
