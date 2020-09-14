//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalFeedImageDataLoader {
    let store: FeedImageDataStore

    public typealias SaveResult = FeedImageDataStore.InsertionResult

    private class Task: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(
                with: result
                    .mapError { _ in Error.failed }
                    .flatMap { data in data.map { .success($0) } ?? .failure(Error.notFound) }
            )
        }
        return task
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url, completion: completion)
    }
}
