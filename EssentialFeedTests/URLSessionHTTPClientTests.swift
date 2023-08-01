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
    
    init(session: URLSession = .shared) {
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
    
    func test_urlSession_returnsErrorWhenEncountered() {
        
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://some-url.com")!
        let sut = URLSessionHTTPClient()
        let error = NSError(domain: "an error", code: 0)
        URLProtocolStub.stub(url: url, error: error)
        
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
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        var requestedURLs: [URL] = []
        private static var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = .init(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
