//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 11.10.2023.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    
    var models: [FeedCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var refreshController: FeedRefreshViewController?
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    public override var refreshControl: UIRefreshControl? {
        didSet {
            refreshController?.view = refreshControl!
        }
    }
    
    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = refreshController?.view
        
        onViewIsAppearing = { vc in
            vc.refreshController?.load()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedCellController {
        models[indexPath.row]
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).view()
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).loadImage(forCell: cell as? FeedItemCell)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelLoad()
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(at: $0).loadImage(forCell: nil) }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(at: $0).cancelLoad() }
    }
}
