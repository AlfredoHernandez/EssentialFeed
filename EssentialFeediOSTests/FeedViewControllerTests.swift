//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.FeedLoaderSpy) {
        
    }
}
 
class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = FeedLoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class FeedLoaderSpy {
        var loadCallCount = 0
    }
}
