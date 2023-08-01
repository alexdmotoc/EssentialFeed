//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 01.08.2023.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(response: HTTPURLResponse, data: Data), Error>
    
    func get(url: URL, completion: @escaping (Result) -> Void)
}
