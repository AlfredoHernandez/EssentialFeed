//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

class LocalFeedImageDataLoader {
    let store: FeedImageDataStore

    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    public enum Error: Swift.Error {
        case failed
    }

    init(store: FeedImageDataStore) {
        self.store = store
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            switch result {
            case .failure:
                completion(.failure(Error.failed))
            default: break
            }
        }
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

    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let anyError = anyNSError()

        let exp = expectation(description: "Wait for result")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error as? LocalFeedImageDataLoader.Error, .failed)
            default:
                XCTFail("Expected failure, got \(result) instead.")
            }
            exp.fulfill()
        }

        store.complete(with: .failure(anyError))
        wait(for: [exp], timeout: 1.0)
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
        var completions = [(FeedImageDataLoader.Result) -> Void]()

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            messages.append(.retrieve(dataForUrl: url))
            completions.append(completion)
        }

        func complete(with result: FeedImageDataStore.Result, at index: Int = 0) {
            completions[index](result)
        }
    }
}
