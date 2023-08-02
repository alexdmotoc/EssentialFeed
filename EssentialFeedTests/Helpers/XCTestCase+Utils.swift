//
//  XCTestCase+Utils.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 02.08.2023.
//

import XCTest

extension XCTestCase {
    func checkIsDeallocated(
        sut: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, file: file, line: line)
        }
    }
}
