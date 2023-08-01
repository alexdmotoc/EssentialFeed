//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 01.08.2023.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url) { _, _, _ in
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_urlSession_callsDataTaskWithURL() {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://some-url.com")!
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
    func test_urlSession_resumesDataTaskWithURL() {
        
        let session = URLSessionSpy()
        let url = URL(string: "https://some-url.com")!
        let task = URLSessionDataTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        session.stub(url, task)
        
        sut.get(url: url)
        
        XCTAssertEqual(task.countOfResumeMethod, 1)
    }
    
    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var requestedURLs: [URL] = []
        private var stubs: [URL: URLSessionDataTask] = [:]
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(_ url: URL, _ task: URLSessionDataTask) {
            stubs[url] = task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var countOfResumeMethod = 0
        
        override func resume() {
            countOfResumeMethod += 1
        }
    }
}
