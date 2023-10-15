//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject {
    lazy var view = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(self.load), for: .valueChanged)
        return view
    }
        
    @objc func load() {
        delegate.didRequestFeedRefresh()
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
