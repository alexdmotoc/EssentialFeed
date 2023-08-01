//
//  RemoteFeedLoader.swift
//  
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL)
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(url: url)
    }
}
