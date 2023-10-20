//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import UIKit
import EssentialFeediOS

extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedImages: Int {
        tableView.numberOfRows(inSection: itemsSection)
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    // MARK: - Initialization support
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForInitialAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func prepareForInitialAppearance() {
        replaceRefreshControlWithSpyForiOS17Support()
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
    
    // MARK: - Utility
    
    var itemsSection: Int { 0 }
    
    func itemCell(at index: Int) -> FeedItemCell? {
        guard index < numberOfRenderedImages else { return nil }
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: itemsSection)) as? FeedItemCell
    }
    
    @discardableResult
    func simulateCellIsVisible(at index: Int) -> FeedItemCell {
        let cell = itemCell(at: index)!
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: itemsSection))
        return cell
    }
    
    @discardableResult
    func simulateCellIsNotVisible(at index: Int) -> FeedItemCell {
        let cell = simulateCellIsVisible(at: index)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: index, section: itemsSection))
        return cell
    }
    
    func simulateCellIsRedisplayed(_ cell: FeedItemCell, at index: Int) {
        tableView.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: index, section: itemsSection))
    }
    
    func simulateManualFeedLoad() {
        refreshControl?.simulateManualRefresh()
    }
    
    func simulateCellPreload(at index: Int) {
        tableView.prefetchDataSource?.tableView(tableView, prefetchRowsAt: [IndexPath(row: index, section: itemsSection)])
    }
    
    func simulateCancelCellPreload(at index: Int) {
        simulateCellPreload(at: index)
        tableView.prefetchDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [IndexPath(row: index, section: itemsSection)])
    }
    
    func renderedImageData(at index: Int) -> Data? {
        simulateCellIsVisible(at: index).renderedImageData
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
