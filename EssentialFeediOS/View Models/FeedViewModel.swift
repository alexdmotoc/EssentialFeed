//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let loader: FeedLoader
    
    var onIsLoadingStateChange: Observer<Bool>?
    var onFeedStateChange: Observer<[FeedItem]>?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func load() {
        onIsLoadingStateChange?(true)
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.onFeedStateChange?(items)
            }
            self?.onIsLoadingStateChange?(false)
        }
    }
}
