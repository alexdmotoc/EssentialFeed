//
//  EssentialAppAcceptanceUITests.swift
//  EssentialAppAcceptanceUITests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest

final class EssentialAppAcceptanceUITests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launch()
        
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let imageView = feedCells.firstMatch.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(imageView.exists)
    }
    
    func test_onLaunch_displaysCachedFeedWhenThereIsNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let feedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)
        
        let imageView = offlineApp.firstMatch.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(imageView.exists)
    }
}
