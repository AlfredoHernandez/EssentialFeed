//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, imageLoader: imageLoader)
        return feedController
    }

    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        imageLoader: FeedImageDataLoader
    ) -> (([FeedImage]) -> Void) {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { image in
                FeedImageCellController(model: image, imageLoader: imageLoader)
            }
        }
    }
}
