//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedLoaderWithFallbackComposite: FeedLoader {
    init(primary: FeedLoader, fallback: FeedLoader) {
        
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversRemoteFeedOnRemoteSuccess() {
        let primaryLoader = FeedLoaderStub()
        let fallbackLoader = FeedLoaderStub()
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(receivedFeed, remoteFeed)
            case .failure:
                XCTFail("Expected successful load feed result, but got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: -  Helpers
    
    private class FeedLoaderStub: FeedLoader {
        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            
        }
    }
}
