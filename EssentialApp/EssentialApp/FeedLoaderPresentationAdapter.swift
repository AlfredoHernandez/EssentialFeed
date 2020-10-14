//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import Foundation

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    var presenter: FeedPresenter?
    var cancellables = Set<AnyCancellable>()

    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        feedLoader()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.presenter?.didFinishLoadingFeed(with: error)
                default: break
                }
            }, receiveValue: { [weak self] feed in
                self?.presenter?.didFinishLoadingFeed(with: feed)
            }).store(in: &cancellables)
    }
}
