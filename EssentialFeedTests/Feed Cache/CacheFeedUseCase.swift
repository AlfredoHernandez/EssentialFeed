//
//  Created by Jesús Alfredo Hernández Alarcón on 05/08/20.
//

import XCTest

class LocalFeedLoader {
	init(store: FeedStore) {
		
	}
}

class FeedStore {
	var deleteCacheFeedCallCount = 0
}

class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		
		_ = LocalFeedLoader(store: store)
		
		XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
	}
}
