//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import Foundation

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: FeedPresenter?
    var cancellable: AnyCancellable?

    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                default: break
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            })
    }
}
