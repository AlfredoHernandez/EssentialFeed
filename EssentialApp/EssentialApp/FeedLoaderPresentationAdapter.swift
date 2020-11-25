//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import Foundation

final class LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    var cancellable: AnyCancellable?

    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoading()

        cancellable = feedLoader()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                default: break
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoading(with: feed)
            })
    }
}
