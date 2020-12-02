//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import Foundation

class FeedLoaderSpy: FeedImageDataLoader {
    // MARK: - Feed Loader

    var feedRequests = [PassthroughSubject<[FeedImage], Swift.Error>]()
    var loadFeedCallCount: Int { feedRequests.count }

    func loadPublisher() -> AnyPublisher<[FeedImage], Swift.Error> {
        let publisher = PassthroughSubject<[FeedImage], Swift.Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }

    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index].send(feed)
    }

    func completeFeedLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }

    // MARK: - Feed Image Data Loader

    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    var loadedImageURLs: [URL] {
        imageRequests.map(\.url)
    }

    private(set) var cancelledImageURLs = [URL]()

    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void

        func cancel() {
            cancelCallback()
        }
    }

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }

    func completeImageLoading(with data: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(data))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "any error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
