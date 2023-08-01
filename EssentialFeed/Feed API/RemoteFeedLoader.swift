//
//  RemoteFeedLoader.swift
//  
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<HTTPURLResponse, Error>
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidResponse
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(url: url) { result in
            switch result {
            case .success:
                completion(.invalidResponse)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
