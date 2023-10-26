//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 17.10.2023.
//

import Foundation

public enum FeedImagePresenter {
    public static func map(_ item: FeedItem) -> FeedImageViewModel {
        .init(description: item.description, location: item.location)
    }
}
