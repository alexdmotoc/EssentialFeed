//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Alex Motoc on 01.08.2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        URLProtocolStub.removeStub()
        super.tearDown()
    }
    
    func test_getURL_returnsErrorWhenEncountered() {
        
        let error = makeNSError()
        
        let encounteredError = getResultingError((data: nil, response: nil, error: error)) as? NSError
        
        XCTAssertEqual(error.domain, encounteredError?.domain)
        XCTAssertEqual(error.code, encounteredError?.code)
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
        XCTAssertNotNil(getResultingError((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(getResultingError((data: nil, response: makeURLResponse(), error: nil)))
        XCTAssertNotNil(getResultingError((data: makeData(), response: nil, error: nil)))
        XCTAssertNotNil(getResultingError((data: makeData(), response: nil, error: makeNSError())))
        XCTAssertNotNil(getResultingError((data: nil, response: makeURLResponse(), error: makeNSError())))
        XCTAssertNotNil(getResultingError((data: nil, response: makeHTTPURLResponse(), error: makeNSError())))
        XCTAssertNotNil(getResultingError((data: makeData(), response: makeURLResponse(), error: makeNSError())))
        XCTAssertNotNil(getResultingError((data: makeData(), response: makeHTTPURLResponse(), error: makeNSError())))
        XCTAssertNotNil(getResultingError((data: makeData(), response: makeURLResponse(), error: nil)))
    }
    
    func test_getURL_retrievesDataAndHTTPURLResponse() {
        let data = makeData()
        let response = makeHTTPURLResponse()
        
        let result = getResultingValues((data: data, response: response, error: nil))
        
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    func test_getURL_retrievesEmptyDataWhenStubbedDataIsNilAndResponseIsHTTPURLResponse() {
        let response = makeHTTPURLResponse()
        
        let result = getResultingValues((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(result?.data, emptyData)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    func test_cancelTask_returnsError() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { _ in exp.fulfill() }
        
        let cancelError = getResultingError(taskHandler: { $0.cancel() }) as? NSError
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(cancelError?.code, URLError.cancelled.rawValue)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    private func makeData() -> Data {
        .init("some data".utf8)
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
    
    private func getResultingError(
        _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
        taskHandler: ((HTTPClientTask) -> Void) = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        
        guard let result = getResult(values, taskHandler: taskHandler, file: file, line: line) else {
            return nil
        }
        switch result {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    private func getResultingValues(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        taskHandler: ((HTTPClientTask) -> Void) = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (response: HTTPURLResponse, data: Data)? {
        
        guard let result = getResult(values, taskHandler: taskHandler, file: file, line: line) else {
            return nil
        }
        switch result {
        case .success(let data):
            return data
        case .failure:
            return nil
        }
    }
    
    private func getResult(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        taskHandler: ((HTTPClientTask) -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result? {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        
        let exp = expectation(description: "wait for request to complete")
        var encounteredResult: HTTPClient.Result?
        taskHandler(makeSUT(file: file, line: line).get(url: makeURL()) { result in
            encounteredResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1)
        
        return encounteredResult
    }
}
