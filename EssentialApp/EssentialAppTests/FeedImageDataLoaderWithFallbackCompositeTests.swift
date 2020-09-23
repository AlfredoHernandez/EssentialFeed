//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

class FeedImageDataLoaderWithFallbackComposite {
    init(primary _: FeedImageDataLoader, fallback _: FeedImageDataLoader) {}
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderStub()
        let fallbackLoader = LoaderStub()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }

    // MARK: -  Helpers

    private class LoaderStub: FeedImageDataLoader {
        private class FeedImageDataLoaderTaskFake: FeedImageDataLoaderTask {
            func cancel() {}
        }

        var loadedURLs = [URL]()

        func loadImageData(from url: URL, completion _: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            loadedURLs.append(url)
            return FeedImageDataLoaderTaskFake()
        }
    }
}
