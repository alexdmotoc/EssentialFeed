//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_map_mapsCorrectly() {
        let items = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(items)
        
        XCTAssertEqual(viewModel.feed, items)
    }
    
    // MARK: - Helpers
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
    }
}
