//
//  FeedLoader.swift
//  
//
//  Created by Alex Motoc on 31.07.2023.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping (Result<[FeedItem], Error>) -> Void)
}
