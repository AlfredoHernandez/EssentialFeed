//
//  Created by Jesús Alfredo Hernández Alarcón on 05/08/20.
//

import XCTest
import EssentialFeed

class CacheFeedUseCase: XCTestCase {
	
	func test_init_doesNotMessageStoreCacheUponCreation() {
		let (_, store) = makeSUT()
		
		XCTAssertEqual(store.receivedMessages, [])
	}
	
	func test_save_requestCacheDeletion() {
		let (sut, store) = makeSUT()
		
		sut.save(uniqueItems().models) { _ in }
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError
		
		sut.save(uniqueItems().models) { _ in }
		store.completeDeletion(with: deletionError)
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
	}
	
	func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let items = uniqueItems()
		
		sut.save(items.models) { _ in }
		store.completeDeletionSuccessfully()
		
		XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items.local, timestamp)])
	}
	
	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: anyNSError, when: {
			store.completeDeletion(with: anyNSError)
		})
	}
	
	func test_save_failsOnInsertionError() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: anyNSError, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: anyNSError)
		})
	}
	
	func test_save_succeedsOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()
		
		expect(sut, toCompleteWithError: nil, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		})
	}
	
	func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
		let timestamp = Date()
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { timestamp })
		
		var receivedErrors = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueItems().models, completion: { receivedErrors.append($0) })
		sut = nil
		store.completeDeletion(with: anyNSError)
		
		XCTAssertTrue(receivedErrors.isEmpty)
	}
	
	func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
		let timestamp = Date()
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { timestamp })
		
		var receivedErrors = [LocalFeedLoader.SaveResult]()
		sut?.save(uniqueItems().models, completion: { receivedErrors.append($0) })
		store.completeDeletionSuccessfully()
		sut = nil
		store.completeInsertion(with: anyNSError)
		
		XCTAssertTrue(receivedErrors.isEmpty)
	}
	
	// MARK: - Test Helpers
	
	private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (sut, store)
	}
	
	private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		let exp = expectation(description: "Wait for save completion")
		var receivedError: Error?
		
		sut.save(uniqueItems().models) { error in
			receivedError = error
			exp.fulfill()
		}
		action()
		
		wait(for: [exp], timeout: 1.0)
		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
	
	private func uniqueItem() -> FeedItem {
		FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}
	
	private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
		let items = [uniqueItem(), uniqueItem()]
		let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
		return (items, localItems)
	}
	
	private func anyURL() -> URL {
		URL(string: "http://any-url.com")!
	}
	
	private var anyNSError: NSError {
		NSError(domain: "any error", code: 1)
	}
	
	private class FeedStoreSpy: FeedStore {
		enum ReceivedMessage: Equatable {
			case deleteCacheFeed
			case insert([LocalFeedItem], Date)
		}
		
		private (set) var receivedMessages = [ReceivedMessage]()
		private var deletionCompletions = [DeletionCompletion]()
		private var insertionCompletions = [InsertionCompletion]()
		
		func deleteCachedFeed(completion: @escaping DeletionCompletion) {
			deletionCompletions.append(completion)
			receivedMessages.append(.deleteCacheFeed)
		}
		
		func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
			insertionCompletions.append(completion)
			receivedMessages.append(.insert(items, timestamp))
		}
		
		func completeDeletion(with error: Error, at index: Int = 0) {
			deletionCompletions[index](error)
		}
		
		func completeDeletionSuccessfully(at index: Int = 0) {
			deletionCompletions[index](nil)
		}
		
		func completeInsertion(with error: Error, at index: Int = 0) {
			insertionCompletions[index](error)
		}
		
		func completeInsertionSuccessfully(at index: Int = 0) {
			insertionCompletions[index](nil)
		}
	}
}
