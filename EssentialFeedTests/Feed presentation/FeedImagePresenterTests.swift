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

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
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
    
    func didStartLoadingImage(for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                isRetryHidden: true
            )
        )
    }
    
    func didEndLoadingImage(with error: Error, for model: FeedItem) {
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                isRetryHidden: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didEndLoadingImage(with data: Data, for model: FeedItem) {
        guard let image = imageTransformer(data) else {
            didEndLoadingImage(with: InvalidImageDataError(), for: model)
            return
        }
        view.display(
            FeedImageViewModel(
                description: model.description,
                location: model.location,
                image: image,
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
    
    func test_didStartLoadingImage_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        let item = uniqueImage()
        
        sut.didStartLoadingImage(for: item)
        
        XCTAssertEqual(spy.messages, [loadingViewModel(for: item)])
    }
    
    func test_didEndLoadingImageWithError_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        let item = uniqueImage()
        
        sut.didEndLoadingImage(with: anyNSError(), for: item)
        
        XCTAssertEqual(spy.messages, [retryViewModel(for: item)])
    }
    
    func test_didEndLoadingImageSuccessfully_onFailedImageDataConversion_sendsCorrectMessage() {
        let (sut, spy) = makeSUT(isFailingToConvert: true)
        let item = uniqueImage()
        
        sut.didEndLoadingImage(with: Data(), for: item)
        
        XCTAssertEqual(spy.messages, [retryViewModel(for: item)])
    }
    
    func test_didEndLoadingImageSuccessfully_onSuccessfulImageDataConversion_sendsCorrectMessage() {
        let (sut, spy) = makeSUT()
        let item = uniqueImage()
        let imageData = Data()
        
        sut.didEndLoadingImage(with: imageData, for: item)
        
        XCTAssertEqual(spy.messages, [loadedViewModel(for: item, image: imageData)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(isFailingToConvert: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, Data>, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = FeedImagePresenter(
            view: spy,
            imageTransformer: isFailingToConvert ? { _ in nil} : { $0 }
        )
        checkIsDeallocated(sut: spy, file: file, line: line)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func dequeueViewModel(for item: FeedItem) -> FeedImageViewModel<Data> {
        .init(description: item.description, location: item.location, image: nil, isLoading: false, isRetryHidden: true)
    }
    
    private func loadingViewModel(for item: FeedItem) -> FeedImageViewModel<Data> {
        .init(description: item.description, location: item.location, image: nil, isLoading: true, isRetryHidden: true)
    }
    
    private func retryViewModel(for item: FeedItem) -> FeedImageViewModel<Data> {
        .init(description: item.description, location: item.location, image: nil, isLoading: false, isRetryHidden: false)
    }
    
    private func loadedViewModel(for item: FeedItem, image: Data) -> FeedImageViewModel<Data> {
        .init(description: item.description, location: item.location, image: image, isLoading: false, isRetryHidden: true)
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
