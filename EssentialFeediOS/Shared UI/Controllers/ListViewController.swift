//
//  ListViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 11.10.2023.
//

import UIKit
import EssentialFeed

public class ListViewController: UITableViewController {
    
    private(set) public lazy var errorView = ErrorView()
    
    private var models: [CellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    private var loadingControllers: [IndexPath: CellController] = [:]
    private var onViewIsAppearing: ((ListViewController) -> Void)?
    
    public var onRefresh: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = errorView
        
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
    
    public func display(_ models: [CellController]) {
        self.models = models
        loadingControllers = [:]
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController {
        models[indexPath.row]
    }
    
    private func removeLoadController(at indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
    
    private func addLoadController(at indexPath: IndexPath) -> CellController {
        let controller = cellController(at: indexPath)
        loadingControllers[indexPath] = controller
        return controller
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
}

// MARK: - FeedLoadingView

extension ListViewController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}

// MARK: - FeedErrorView

extension ListViewController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}

// MARK: - UITableViewDataSource

extension ListViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(at: indexPath)
        return controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
    }
}

// MARK: - UITableViewDelegate

extension ListViewController {
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = addLoadController(at: indexPath)
        controller.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadController(at: indexPath)
        controller?.delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension ListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = addLoadController(at: indexPath)
            controller.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadController(at: indexPath)
            controller?.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
}
