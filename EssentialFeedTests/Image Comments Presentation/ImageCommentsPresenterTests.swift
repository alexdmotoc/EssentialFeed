//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 26.10.2023.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {
    func test_presenter_hasTitle() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_map_returnsCorrectViewModels() {
        let now = Date.now
        let calendar = Calendar.current
        let locale = Locale(identifier: "en_US_POSIX")
        let comment1 = ImageComment(id: UUID(), message: "a message", createdAt: now.adding(minutes: -5, calendar: calendar), username: "a username")
        let comment2 = ImageComment(id: UUID(), message: "another message", createdAt: now.adding(days: -1, calendar: calendar), username: "another username")
        
        let viewModel = ImageCommentsPresenter.map([comment1, comment2], calendar: calendar, locale: locale, currentDate: now)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(message: "a message", date: "5 minutes ago", username: "a username"),
            ImageCommentViewModel(message: "another message", date: "1 day ago", username: "another username")
        ])
    }
    
    // MARK: - Helpers
    
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: "ImageComments")
        if localizedString == key {
            XCTFail("Couldn't find a localized string for key \(key)", file: file, line: line)
        }
        return localizedString
    }
}
