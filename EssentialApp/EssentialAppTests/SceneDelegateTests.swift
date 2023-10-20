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
    func test_sceneDelegate_setsRootViewControllerCorrectly() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        
        sut.configureWindow()
        
        let navController = sut.window?.rootViewController as? UINavigationController
        XCTAssertNotNil(navController)
        XCTAssertTrue(navController?.topViewController is FeedViewController)
    }
}
