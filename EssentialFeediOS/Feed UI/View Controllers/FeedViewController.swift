//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 11.10.2023.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public class FeedViewController: UITableViewController {
    
    @IBOutlet private(set) public var errorView: ErrorView!
    
    private var models: [FeedCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var loadingControllers: [IndexPath: FeedCellController] = [:]
    
    public var delegate: FeedViewControllerDelegate?
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        onViewIsAppearing = { vc in
            vc.refresh()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.autoSizeHeader()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    public func display(_ models: [FeedCellController]) {
        self.models = models
        loadingControllers = [:]
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedCellController {
        models[indexPath.row]
    }
    
    private func cancelLoadingImage(at indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
    private func startLoadingImage(at indexPath: IndexPath, forCell cell: FeedItemCell? = nil) {
        let controller = cellController(at: indexPath)
        loadingControllers[indexPath] = controller
        controller.loadImage(forCell: cell)
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

// MARK: - FeedLoadingView

extension FeedViewController: FeedLoadingView {
    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - FeedErrorView

extension FeedViewController: FeedErrorView {
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView.message = viewModel.message
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
        startLoadingImage(at: indexPath, forCell: cell as? FeedItemCell)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoadingImage(at: indexPath)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { startLoadingImage(at: $0) }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelLoadingImage(at: $0) }
    }
}
