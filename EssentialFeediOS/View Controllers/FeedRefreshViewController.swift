//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    var view = UIRefreshControl()
    var onRefresh: (([FeedItem]) -> Void)?
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
        super.init()
        view.addTarget(self, action: #selector(self.load), for: .valueChanged)
    }
    
    @objc func load() {
        view.beginRefreshing()
        loader.load { [weak self] result in
            if let items = try? result.get() {
                self?.onRefresh?(items)
            }
            self?.view.endRefreshing()
        }
    }
}
