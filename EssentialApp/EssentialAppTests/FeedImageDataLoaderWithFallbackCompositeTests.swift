//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func loadImageData(from url: URL, completion _: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure:
                _ = self?.fallback.loadImageData(from: url) { _ in }
            }
        }
        return Task()
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()

        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primaryLoader.loadedURLs, [url])
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }

    func test_loadImageData_loadsFromFallbackOnPrimaryLoaderFailure() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()

        _ = sut.loadImageData(from: url) { _ in }

        primaryLoader.complete(with: anyNSError())

        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackLoader.loadedURLs, [url], "Expected to load URL from fallback loader")
    }

    // MARK: -  Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }

    private func anyNSError() -> Error {
        NSError(domain: "any error", code: 0)
    }

    private class LoaderSpy: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }

        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }

        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
