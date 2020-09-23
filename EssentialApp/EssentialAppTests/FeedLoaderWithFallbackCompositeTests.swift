//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import XCTest

class FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader

    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        primary.load { [self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                fallback.load(completion: completion)
            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected successful load feed result, but got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversFallbackFeedOnPrimaryFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(NSError(domain: "any error", code: 1)), fallbackResult: .success(fallbackFeed))

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, fallbackFeed)
            case .failure:
                XCTFail("Expected successful load feed result, but got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

    func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "http://any-url.com")!)]
    }

    private class LoaderStub: FeedLoader {
        let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            completion(result)
        }
    }
}
