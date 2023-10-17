//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    private let errorView: FeedErrorView
    
    private static var loadError: String {
        String(
            localized: "FEED_LOAD_ERROR",
            table: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when loading fails"
        )
    }
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
        self.errorView = errorView
    }
    
    func didStartLoading() {
        errorView.display(.noError)
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoading(with feed: [FeedItem]) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
        feedView.display(FeedViewModel(feed: feed))
    }
    
    func didEndLoading(with error: Error) {
        errorView.display(.error(message: FeedPresenter.loadError))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

final class FeedPresenterTests: XCTestCase {

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
    
    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "Feed")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
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
