//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class LocalFeedImageDataLoader {
    init(store: Any) { }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let store = FeedStoreSpy()
        _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    private class FeedStoreSpy {
        var messages = [Any]()
    }
}
