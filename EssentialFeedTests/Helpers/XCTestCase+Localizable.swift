//
//  XCTestCase+Localizable.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
    }
}
