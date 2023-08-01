//
//  FeedLoader.swift
//  
//
//  Created by Alex Motoc on 31.07.2023.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
