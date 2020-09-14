//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.messages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()

        sut.save(data, for: url) { _ in }

        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        let expectedError = anyNSError()

        let exp = expectation(description: "Wait for save")
        sut.save(data, for: url) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as? LocalFeedImageDataLoader.SaveError, LocalFeedImageDataLoader.SaveError.failed)
            default:
                XCTFail("Expected error, but got \(result) instead.")
            }
            exp.fulfill()
        }
        
        store.completeInsertion(with: expectedError)
        
        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
