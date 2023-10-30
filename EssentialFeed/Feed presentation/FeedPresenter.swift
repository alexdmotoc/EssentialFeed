//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public final class FeedPresenter {
    
    public static var title: String {
        String(
            localized: "FEED_VIEW_TITLE",
            table: "Feed",
            bundle: Bundle(for: Self.self),
            comment: "The title of the main screen"
        )
    }
}
