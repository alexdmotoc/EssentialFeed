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
    
    func test_init_doesNotSendAnyMessages() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_startLoading_sendsCorrectMessages() {
        let (sut, spy) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(spy.messages, [.display(error: nil), .display(isLoading: true)])
    }
    
    func test_endLoadingSuccessfully_sendsCorrectMessages() {
        let (sut, spy) = makeSUT()
        let feed = uniqueImageFeed().models
        
        sut.didEndLoading(with: feed)
        
        XCTAssertEqual(spy.messages, [.display(isLoading: false), .display(feed: feed)])
    }
    
    func test_endLoadingWithError_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        
        sut.didEndLoading(with: anyNSError())
        
        XCTAssertEqual(spy.messages, [.display(error: localized("FEED_LOAD_ERROR")), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedPresenter(feedLoadingView: spy, feedView: spy, errorView: spy)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    private class ViewSpy: FeedLoadingView, FeedErrorView, FeedView {
        
        enum Message: Equatable {
            case display(error: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedItem])
        }
        
        private(set) var messages: [Message] = []
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(error: viewModel.message))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.append(.display(feed: viewModel.feed))
        }
    }
}
