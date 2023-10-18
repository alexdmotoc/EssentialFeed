//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Alex Motoc on 09.10.2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        clearCoreDataStore()
    }

    override func tearDown() {
        clearCoreDataStore()
        super.tearDown()
    }

    func test_load_onEmptyCacheDeliversNoItems() throws {
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    func test_load_onItemsSavedOnOneInstanceDeliversItemsOnAnotherInstance() {
        let sutToSave = makeSUT()
        let sutToLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(to: sutToSave, items: feed)
        
        expect(sutToLoad, toLoad: feed)
    }
    
    func test_save_overwritesPreviouslyStoredItems() {
        let sutToSaveFirst = makeSUT()
        let sutToSaveLast = makeSUT()
        let sutToLoad = makeSUT()
        let feedFirst = uniqueImageFeed().models
        let feedLast = uniqueImageFeed().models
        
        save(to: sutToSaveFirst, items: feedFirst)
        save(to: sutToSaveLast, items: feedLast)
        
        expect(sutToLoad, toLoad: feedLast)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let store = try! CoreDataFeedStore(storeURL: storeURL())
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        checkIsDeallocated(sut: sut, file: file, line: line)
        return sut
    }
    
    func expect(_ sut: LocalFeedLoader, toLoad expectedItems: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load")
        
        sut.load { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case .failure(let error):
                XCTFail("Expected items got error \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func save(to sut: LocalFeedLoader, items: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for save")
        
        sut.save(items) { error in
            XCTAssertNil(error, file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func storeURL() -> URL {
        cacheDirectory().appending(component: "\(type(of: self)).store")
    }
    
    func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func clearCoreDataStore() {
        try? FileManager.default.removeItem(at: storeURL())
    }
}
