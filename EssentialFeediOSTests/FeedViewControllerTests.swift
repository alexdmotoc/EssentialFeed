//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 11.10.2023.
//

import XCTest

class FeedViewController {
    
}

class LoaderSpy {
    var loadCount = 0
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let sut = FeedViewController()
        let loader = LoaderSpy()
        
        XCTAssertEqual(loader.loadCount, 0)
    }

}
