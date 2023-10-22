//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 20.10.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_setsRootViewControllerCorrectly() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let navController = sut.window?.rootViewController as? UINavigationController
        XCTAssertNotNil(navController)
        XCTAssertTrue(navController?.topViewController is FeedViewController)
    }
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let sut = SceneDelegate()
        let window = WindowSpy()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCount, 1)
    }
    
    // MARK: - Helpers
    
    private class WindowSpy: UIWindow {
        private(set) var makeKeyAndVisibleCount = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCount += 1
        }
    }
}
