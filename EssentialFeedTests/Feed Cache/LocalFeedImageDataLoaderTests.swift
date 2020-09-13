//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}

class LocalFeedImageDataLoader {
    let store: FeedImageDataStore

    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion _: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.messages.isEmpty)
    }

    func test_loadImageDataFromURL_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(store.messages, [.retrieve(dataForUrl: url)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private class FeedStoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(dataForUrl: URL)
        }

        var messages = [Message]()

        func retrieve(dataForURL url: URL) {
            messages.append(.retrieve(dataForUrl: url))
        }
    }
}
