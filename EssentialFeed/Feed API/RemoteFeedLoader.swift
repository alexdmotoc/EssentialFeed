//
//  RemoteFeedLoader.swift
//  
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidResponse
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(url: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((response, data)):
                completion(FeedItemMapper.map(response: response, data: data))
            case .failure:
                completion(.failure(Self.Error.connectivity))
            }
        }
    }
}
