//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    lazy var view = loadView()
    
    private let loadFeed: () -> Void
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
        super.init()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(self.load), for: .valueChanged)
        return view
    }
        
    @objc func load() {
        loadFeed()
    }
}

extension FeedRefreshViewController: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
