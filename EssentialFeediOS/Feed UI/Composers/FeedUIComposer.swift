//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        presentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(refreshController)
        )
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ viewModel: ViewModel<UIImage>) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader

    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { image in
            let presenter = FeedImagePresenter<FeedImageCellController, UIImage>(
                model: image,
                imageLoader: imageLoader,
                imageTransformer: UIImage.init
            )
            let presentationAdapter = FeedImageDataLoaderPresentationAdapter(model: image, imageLoader: imageLoader, presenter: presenter)
            let controller = FeedImageCellController(delegate: presentationAdapter)
            presenter.view = controller
            return controller
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate
    where View.Image == Image
{
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let presenter: FeedImagePresenter<View, Image>
    private var task: FeedImageDataLoaderTask?

    init(model: FeedImage, imageLoader: FeedImageDataLoader, presenter: FeedImagePresenter<View, Image>) {
        self.model = model
        self.imageLoader = imageLoader
        self.presenter = presenter
    }

    func didRequestImage() {
        presenter.didStartLoadingImageData(for: model)

        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }

    func didCancelImageRequest() {
        task?.cancel()
    }

    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
}
