//
//  ImageCommentsEndpoont.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 28.10.2023.
//

import Foundation

public enum ImageCommentsEndpoont {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let id):
            return baseURL.appending(path: "/v1/image/\(id)/comments")
        }
    }
}
