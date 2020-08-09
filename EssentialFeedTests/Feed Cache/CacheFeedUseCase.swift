//
//  Created by Jesús Alfredo Hernández Alarcón on 05/08/20.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
	private let store: FeedStore
	private let currentDate: () -> Date
	
	init(store: FeedStore, currentDate: @escaping () -> Date) {
		self.store = store
		self.currentDate = currentDate
	}
	
	func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
		store.deleteCachedFeed { [unowned self] error in
			completion(error)
			if error == nil {
				self.store.insert(items, timestamp: self.currentDate())
			}
		}
	}
}

class FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	
	enum ReceivedMessage: Equatable {
		case deleteCacheFeed
		case insert([FeedItem], Date)
	}
	
	private (set) var receivedMessages = [ReceivedMessage]()
	private var deletionCompletions = [DeletionCompletion]()
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCacheFeed)
	}
	
	func insert(_ items: [FeedItem], timestamp: Date) {
		receivedMessages.append(.insert(items, timestamp))
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](error)
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](nil)
	}
}

class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotMessageStoreCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_save_requestCacheDeletion() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError
		
		sut.save(items) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let items = [uniqueItem(), uniqueItem()]
		
		sut.save(items) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
	}
	
	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let items = [uniqueItem(), uniqueItem()]
		let deletionError = anyNSError
		let exp = expectation(description: "Wait for save completion")
		
		var receivedError: Error?
		sut.save(items) { error in
			receivedError = error
			exp.fulfill()
		}
		store.completeDeletion(with: deletionError)
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertEqual(receivedError as NSError?, deletionError)
	}
	
	// MARK: - Test Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
		let store = FeedStore()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
