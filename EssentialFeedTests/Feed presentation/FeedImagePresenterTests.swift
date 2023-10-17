//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest

final class FeedImagePresenter {
    private let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesntSendAnyMessages() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedImagePresenter(view: spy)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    private class ViewSpy {
        private(set) var messages: [Any] = []
    }
    
}
