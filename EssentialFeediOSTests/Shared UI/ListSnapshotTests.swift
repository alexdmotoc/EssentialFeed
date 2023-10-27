//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 21.10.2023.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

final class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_feedWithError() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark, contentSize: .extraExtraExtraLarge)), named: "LIST_WITH_ERROR_dark_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.backgroundColor = .systemGroupedBackground
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyList() -> [CellController] {
        []
    }
}
