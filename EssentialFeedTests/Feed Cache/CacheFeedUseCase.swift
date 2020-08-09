//
//  Created by Jesús Alfredo Hernández Alarcón on 05/08/20.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
	let store: FeedStore
	
	init(store: FeedStore) {
		self.store = store
	}
	
	func save(_ items: [FeedItem]) {
		store.deleteCachedFeed { [unowned self] error in
			if error == nil {
				self.store.insert(items)
			}
		}
	}
}

class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	var deleteCachedFeedCallCount = 0
	var insertCallCount = 0
	
	private var deletionCompletions = [DeletionCompletion]()
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deleteCachedFeedCallCount += 1
		deletionCompletions.append(completion)
	}
	
	func insert(_ items: [FeedItem]) {
		insertCallCount += 1
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
}

class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotDeleteCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}
	
	func test_save_requestCacheDeletion() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items)
		
		XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError
		
		sut.save(items)
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.insertCallCount, 0)
	}
	
	func test_save_requestNewCacheInsertionOnSuccessfullDeletion() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items)
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.insertCallCount, 1)
	}
	
	// MARK: - Test Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func uniqueItem() -> FeedItem {
		FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}
	
	private func anyURL() -> URL {
		URL(string: "http://any-url.com")!
	}
	
	private var anyNSError: NSError {
		NSError(domain: "any error", code: 1)
	}
}
