//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 01.08.2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_urlSession_resumesDataTaskWithURL() {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://some-url.com")!
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url: url, task: task)
        
        sut.get(url: url) { _ in }
        
        XCTAssertEqual(task.countOfResumeMethod, 1)
    }
    
    func test_urlSession_returnsErrorWhenEncountered() {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://some-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        let error = NSError(domain: "an error", code: 0)
        session.stub(url: url, error: error)
        
        let exp = expectation(description: "wait for request to complete")
        sut.get(url: url) { result in
            switch result {
            case .failure(let encounteredError as NSError):
                XCTAssertEqual(error, encounteredError)
            default:
                XCTFail("expected to fail with error \(error), got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = .init(task: task, error: error)
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var countOfResumeMethod = 0
        
        override func resume() {
            countOfResumeMethod += 1
        }
    }
}
