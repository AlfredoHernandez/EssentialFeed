//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retreivalError = anyNSError()

        expect(sut, toCompleteWith: .failure(retreivalError), when: {
            store.completeRetrieval(with: retreivalError)
        })
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCacheImagesOnNonExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }

    func test_load_deliversNoImagesOnCacheExpiration() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        })
    }

    func test_load_deliversNoImagesOnExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        })
    }

    func test_load_hasNoSideEffectsOnRetreivalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }

    func expect(
        _ sut: LocalFeedLoader,
        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion.")

        sut.load { receivedresult in
            switch (receivedresult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedresult) instead.")
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
