//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import UIKit
@testable import EssentialFeediOS

// MARK: - iOS 17 support

extension ListViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForInitialAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func prepareForInitialAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithSpyForiOS17Support()
    }
    
    func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    func replaceRefreshControlWithSpyForiOS17Support() {
        let spy = UIRefreshControlSpy()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                spy.addTarget(target, action: Selector($0), for: .valueChanged)
            }
        }
        
        refreshControl = spy
    }
    
    private class UIRefreshControlSpy: UIRefreshControl {
        var _isRefreshing: Bool = false
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}

// MARK: - General

extension ListViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    func simulateManualReload() {
        refreshControl?.simulateManualRefresh()
    }
    
    func simulateErrorMessageTap() {
        errorView.simulateTap()
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

// MARK: - Comments Utility

extension ListViewController {
    
    var commentsSection: Int { 0 }
    
    var numberOfRenderedComments: Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentCell(at index: Int) -> ImageCommentCell? {
        cell(row: index, section: commentsSection) as? ImageCommentCell
    }
}

// MARK: - Feed Utility

extension ListViewController {
    
    var feedSection: Int { 0 }
    var feedLoadMoreSection: Int { 1 }
    
    var numberOfRenderedImages: Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedSection)
    }
    
    func feedCell(at index: Int) -> FeedItemCell? {
        cell(row: index, section: feedSection) as? FeedItemCell
    }
    
    func simulateFeedCellTap(at index: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: index, section: feedSection))
    }
    
    @discardableResult
    func simulateCellIsVisible(at index: Int) -> FeedItemCell {
        let cell = feedCell(at: index)!
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: feedSection))
        return cell
    }
    
    @discardableResult
    func simulateCellIsNotVisible(at index: Int) -> FeedItemCell {
        let cell = feedCell(at: index)!
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: index, section: feedSection))
        return cell
    }
    
    func simulateCellIsRedisplayed(_ cell: FeedItemCell, at index: Int) {
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: feedSection))
    }
    
    func simulateCellPreload(at index: Int) {
        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: feedSection)])
    }
    
    func simulateCancelCellPreload(at index: Int) {
        simulateCellPreload(at: index)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(row: index, section: feedSection)])
    }
    
    func renderedImageData(at index: Int) -> Data? {
        simulateCellIsVisible(at: index).renderedImageData
    }
    
    // MARK: - Load more
    
    func simulateFeedLoadMoreAction() {
        guard let cell = loadMoreFeedCell() else  { return }
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: 0, section: feedLoadMoreSection))
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        return loadMoreFeedCell()?.isLoading == true
    }
    
    var loadMoreError: String? {
        loadMoreFeedCell()?.message
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: 0, section: feedLoadMoreSection) as? LoadMoreCell
    }
}
