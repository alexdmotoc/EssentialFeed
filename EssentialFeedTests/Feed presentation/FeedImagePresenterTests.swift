//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView> {
    private let view: View
    
    init(view: View) {
        self.view = view
    }
    
    func didDequeueCell(for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                isRetryHidden: true
            )
        )
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_init_doesntSendAnyMessages() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_didDequeueCell_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        let item = uniqueImage()
        
        sut.didDequeueCell(for: item)
        
        XCTAssertEqual(spy.messages, [dequeueViewModel(for: item)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy>, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedImagePresenter(view: spy)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func dequeueViewModel(for item: FeedItem) -> FeedImageViewModel<Data> {
        .init(description: item.description, location: item.location, image: nil, isLoading: false, isRetryHidden: true)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = Data
        
        private(set) var messages: [FeedImageViewModel<Data>] = []
        
        func display(_ viewModel: FeedImageViewModel<Data>) {
            messages.append(viewModel)
        }
    }
}

extension FeedImageViewModel: Equatable where Image == Data {
    static func == (lhs: FeedImageViewModel, rhs: FeedImageViewModel) -> Bool {
        lhs.description == rhs.description &&
        lhs.location == rhs.location &&
        lhs.image == rhs.image &&
        lhs.isLoading == rhs.isLoading &&
        lhs.isRetryHidden == rhs.isRetryHidden
    }
}
