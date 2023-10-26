//
//  ResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 17.10.2023.
//

import XCTest
import EssentialFeed

final class ResourcePresenterTests: XCTestCase {
    
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
        let (sut, spy) = makeSUT { resource in
            resource + " view model"
        }
        let resource = "resource"
        
        sut.didEndLoading(with: resource)
        
        XCTAssertEqual(spy.messages, [.display(isLoading: false), .display(resourceViewModel: "resource view model")])
    }
    
    func test_endLoadingSuccessfully_sendsErrorMessagesOnMappingError() {
        let (sut, spy) = makeSUT { _ in throw anyNSError() }
        let resource = "resource"
        
        sut.didEndLoading(with: resource)
        
        XCTAssertEqual(spy.messages, [.display(isLoading: false), .display(error: localized("GENERIC_LOAD_ERROR"))])
    }
    
    func test_endLoadingWithError_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        
        sut.didEndLoading(with: anyNSError())
        
        XCTAssertEqual(spy.messages, [.display(error: localized("GENERIC_LOAD_ERROR")), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SUT, view: ViewSpy) {
        let spy = ViewSpy()
        let sut = SUT(loadingView: spy, resourceView: spy, errorView: spy, mapper: mapper)
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: SUT.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "Shared")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
    }
    
    private class ViewSpy: ResourceLoadingView, ResourceErrorView, ResourceView {
        
        typealias ResourceViewModel = String
        
        enum Message: Hashable {
            case display(error: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }
        
        private(set) var messages: Set<Message> = []
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(error: viewModel.message))
        }
        
        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
    }
}
