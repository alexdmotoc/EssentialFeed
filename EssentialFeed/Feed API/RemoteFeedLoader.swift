//
//  RemoteFeedLoader.swift
//  
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(response: HTTPURLResponse, data: Data), Error>
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidResponse
    }
    
    public typealias Result = Swift.Result<[FeedItem], Error>
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(url: url) { result in
            switch result {
            case let .success((response, data)):
                do {
                    guard response.statusCode == 200 else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    completion(.success(root.items))
                } catch {
                    completion(.failure(.invalidResponse))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
