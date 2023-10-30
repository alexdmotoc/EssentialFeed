//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 26.10.2023.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
    public let message: String
    public let date: String
    public let username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public final class ImageCommentsPresenter {
    public static var title: String {
        String(
            localized: "IMAGE_COMMENTS_VIEW_TITLE",
            table: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "The title of the comments screen"
        )
    }
    
    public static func map(
        _ comments: [ImageComment],
        calendar: Calendar = .current,
        locale: Locale = .current,
        currentDate: Date = .now
    ) -> ImageCommentsViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return ImageCommentsViewModel(comments: comments.map {
            .init(
                message: $0.message,
                date: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
                username: $0.username
            )
        })
    }
}
