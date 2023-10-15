//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 14.10.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    lazy var view = binded(UIRefreshControl()) {
        didSet { observeLoadingStateChange(on: view) }
    }
    
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(self.load), for: .valueChanged)
        observeLoadingStateChange(on: view)
        return view
    }
    
    private func observeLoadingStateChange(on view: UIRefreshControl) {
        viewModel.onIsLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
    }
    
    @objc func load() {
        viewModel.load()
    }
}
