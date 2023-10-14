//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 11.10.2023.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var models: [FeedItem] = []
    private var imageLoadTasks: [IndexPath: FeedImageDataLoaderTask] = [:]
    
    private var onViewIsAppearing: ((FeedViewController) -> Void)?
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.loadFeed), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.loadFeed()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    @objc private func loadFeed() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            switch result {
            case .success(let items):
                self?.models = items
                self?.tableView.reloadData()
            case .failure: break
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func loadImage(at indexPath: IndexPath, forCell cell: FeedItemCell?) {
        let model = models[indexPath.row]
        cell?.retryButton.isHidden = true
        cell?.feedImageContainer.startShimmering()
        imageLoadTasks[indexPath] = imageLoader?.load(from: model.imageURL) { [weak self, weak cell] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            cell?.retryButton.isHidden = image != nil
            cell?.feedImageView.image = image
            cell?.feedImageContainer.stopShimmering()
            self?.imageLoadTasks[indexPath] = nil
        }
    }
    
    private func cancelImageLoad(at indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
        imageLoadTasks[indexPath] = nil
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedItemCell()
        let model = models[indexPath.row]
        cell.descriptionLabel.text = model.description
        cell.descriptionLabel.isHidden = model.description == nil
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = model.location == nil
        cell.onRetry = { [weak self, weak cell] in
            guard let cell else { return }
            self?.loadImage(at: indexPath, forCell: cell)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController {
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadImage(at: indexPath, forCell: cell as? FeedItemCell)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelImageLoad(at: indexPath)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { loadImage(at: $0, forCell: nil) }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelImageLoad(at:))
    }
}
