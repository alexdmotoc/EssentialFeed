//
//  CommentsUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Alex Motoc on 11.10.2023.
//

import XCTest
import EssentialFeed
@testable import EssentialFeediOS
@testable import EssentialApp
import Combine

final class CommentsUIIntegrationTests: XCTestCase {
    
    func test_init_doesNotLoadComments() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.commentsLoadCount, 0)
    }
    
    func test_controller_hasTitle() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.title, ImageCommentsPresenter.title)
    }
    
    func test_viewIsAppearingTwice_loadsTheCommentsOnlyOnce() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        sut.simulateAppearance()
        
        XCTAssertEqual(loader.commentsLoadCount, 1)
    }
    
    func test_loadingComments_requestsLoadFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.commentsLoadCount, 1, "On first appearance the comments are loaded once")
        
        sut.simulateManualReload()
        XCTAssertEqual(loader.commentsLoadCount, 1, "On manual refresh the comments are NOT loaded again until previous request completes")
        
        loader.completeCommentsLoad(at: 0)
        sut.simulateManualReload()
        XCTAssertEqual(loader.commentsLoadCount, 2, "On manual refresh the comments are loaded again")
        
        loader.completeCommentsLoad(at: 1)
        sut.simulateManualReload()
        XCTAssertEqual(loader.commentsLoadCount, 3, "On another manual refresh the comments are loaded again")
    }
    
    func test_loadingIndicator_isShownWheneverALoadIsTriggered() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeCommentsLoad(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeCommentsLoad(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateManualReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeCommentsLoad(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_loadComments_rendersCommentsCorrectly() throws {
        let comment0 = makeComment(message: "some message", username: "some username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        try assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoad(with: [comment0], at: 0)
        try assertThat(sut, isRendering: [comment0])
        
        sut.simulateManualReload()
        loader.completeCommentsLoad(with: [comment0, comment1], at: 1)
        try assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadComments_rendersEmptyCommentsCorrectlyAfterPreviouslyRenderingComments() throws {
        let comment0 = makeComment(message: "some message", username: "some username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeCommentsLoad(with: [comment0, comment1], at: 0)
        try assertThat(sut, isRendering: [comment0, comment1])
        
        sut.simulateManualReload()
        loader.completeCommentsLoad(with: [], at: 1)
        try assertThat(sut, isRendering: [])
    }
    
    func test_loadComments_doesNotAlterRenderingOnError() throws {
        let comment0 = makeComment(message: "some message", username: "some username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoad(with: [comment0], at: 0)
        try assertThat(sut, isRendering: [comment0])
        
        sut.simulateManualReload()
        loader.completeCommentsLoadWithError(at: 1)
        try assertThat(sut, isRendering: [comment0])
    }
    
    func test_loadComments_dispatchesWorkOnMainThread() {
        let comment0 = makeComment(message: "some message", username: "some username")
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        let exp = expectation(description: "wait for complete load")
        DispatchQueue.global().async {
            loader.completeCommentsLoad(with: [comment0], at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadComments_showsErrorOnLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, ResourcePresenter<Any, DummyView>.loadError)
        
        sut.simulateManualReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_onErrorTap_dismissesError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, ResourcePresenter<Any, DummyView>.loadError)
        
        sut.simulateErrorMessageTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_deinit_cancelsRunningLoadRequest() {
        var cancelCount = 0
        
        var sut: ListViewController?
        autoreleasepool {
            sut = CommentsUIComposer.makeCommentsController(with: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCount += 1
                    })
                    .eraseToAnyPublisher()
            })
            sut?.simulateAppearance()
        }
        
        XCTAssertEqual(cancelCount, 0)
        
        sut = nil
        
        XCTAssertEqual(cancelCount, 1)
    }
    
    // MARK: - Helpers
    
    private struct DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.makeCommentsController(with: loader.loadPublisher)
        checkIsDeallocated(sut: loader, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(
        _ sut: ListViewController,
        isRendering comments: [ImageComment],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        sut.view.enforceLayout()
        
        XCTAssertEqual(sut.numberOfRenderedComments, comments.count, file: file, line: line)
        
        let commentsVM = ImageCommentsPresenter.map(comments)
        
        try commentsVM.comments.enumerated().forEach { index, element in
            try assertThat(sut, isRendering: element, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    private func assertThat(
        _ sut: ListViewController,
        isRendering comment: ImageCommentViewModel,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cell = try XCTUnwrap(sut.commentCell(at: index), "Expected to retrieve cell at \(index)", file: file, line: line)
        XCTAssertEqual(cell.messageLabel.text, comment.message, "Expected message to match at \(index)", file: file, line: line)
        XCTAssertEqual(cell.dateLabel.text, comment.date, "Expected date to match at \(index)", file: file, line: line)
        XCTAssertEqual(cell.usernameLabel.text, comment.username, "Expected username to match at \(index)", file: file, line: line)
    }
    
    private func makeComment(message: String, username: String) -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
    
    private class LoaderSpy {
        private var commentsPublishers: [PassthroughSubject<[ImageComment], Error>] = []
        var commentsLoadCount: Int { commentsPublishers.count }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let subject = PassthroughSubject<[ImageComment], Error>()
            commentsPublishers.append(subject)
            return subject.eraseToAnyPublisher()
        }
        
        func completeCommentsLoad(with items: [ImageComment] = [], at index: Int = 0) {
            commentsPublishers[index].send(items)
            commentsPublishers[index].send(completion: .finished)
        }
        
        func completeCommentsLoadWithError(at index: Int = 0) {
            commentsPublishers[index].send(completion: .failure(NSError(domain: "mock", code: 0)))
        }
    }
}
