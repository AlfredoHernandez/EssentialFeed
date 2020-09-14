//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import Foundation

final class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataForUrl: URL)
        case insert(data: Data, for: URL)
        case none
    }

    var messages = [Message]()

    var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        messages.append(.retrieve(dataForUrl: url))
        retrievalCompletions.append(completion)
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        messages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
}
