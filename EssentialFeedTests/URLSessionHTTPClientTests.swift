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
    
    struct LoadError: Error {}
    
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(LoadError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getURL_returnsErrorWhenEncountered() {
        
        let sut = makeSUT()
        let error = makeNSError()
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "wait for request to complete")
        sut.get(url: makeURL()) { result in
            switch result {
            case .failure(let encounteredError as NSError):
                XCTAssertEqual(error.domain, encounteredError.domain)
                XCTAssertEqual(error.code, encounteredError.code)
            default:
                XCTFail("expected to fail with error \(error), got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_getURL_executesTheAppropriateURLRequest() {
        
        let url = makeURL()
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for request to complete")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        
        sut.get(url: url) { _ in }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_getURL_failsWhenInvalidCaseIsEncountered() {
        XCTAssertNotNil(getResultingError(from: nil, response: nil, error: nil))
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        checkIsDeallocated(sut: sut)
        return sut
    }
    
    private func makeURL() -> URL {
        .init(string: "https://some-url.com")!
    }
    
    private func makeNSError() -> NSError {
        .init(domain: "an error", code: 0)
    }
    
    private func makeURLResponse() -> URLResponse {
        .init(url: URL(string: "https://someurl.com")!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeHTTPURLResponse() -> HTTPURLResponse {
        .init(url: URL(string: "https://someurl.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func getResultingError(from data: Data?, response: URLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "wait for request to complete")
        var encounteredError: Error?
        makeSUT().get(url: makeURL()) { result in
            switch result {
            case .failure(let error):
                encounteredError = error
            case .success:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return encounteredError
    }
    
    private class URLProtocolStub: URLProtocol {
        var requestedURLs: [URL] = []
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = .init(data: data, response: response, error: error)
        }
        
        static func observeRequests(closure: @escaping (URLRequest) -> Void) {
            requestObserver = closure
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
