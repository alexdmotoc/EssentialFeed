//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 15.10.2023.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedItem])
}

final class FeedPresenter {
    private let loader: FeedLoader
    weak var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func load() {
        feedLoadingView?.display(isLoading: true)
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.feedView?.display(feed: items)
            }
            self?.feedLoadingView?.display(isLoading: false)
        }
    }
}
