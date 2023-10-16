//
//  FeedUIIntegrationTests+Localizable.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 16.10.2023.
//

import Foundation
import EssentialFeediOS
import XCTest

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedViewController.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
    }
}
