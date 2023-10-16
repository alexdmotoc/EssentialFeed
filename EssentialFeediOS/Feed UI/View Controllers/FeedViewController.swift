//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 11.10.2023.
//

import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedViewController: UITableViewController {
    
    var models: [FeedCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var delegate: FeedViewControllerDelegate?
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        onViewIsAppearing = { vc in
            vc.refresh()
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
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

// MARK: - FeedLoadingView

extension FeedViewController: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).view(in: tableView)
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
        indexPaths.forEach { cellController(at: $0).loadImage() }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(at: $0).cancelLoad() }
    }
}