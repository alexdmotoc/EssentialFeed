//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Alex Motoc on 02.08.2023.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct LoadError: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        private let task: URLSessionTask
        
        init(_ task: URLSessionTask) {
            self.task = task
        }
        
        func cancel() {
            task.cancel()
        }
    }
    
    @discardableResult
    public func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
            } else {
                completion(.failure(LoadError()))
            }
        }
        task.resume()
        return URLSessionTaskWrapper(task)
    }
}
