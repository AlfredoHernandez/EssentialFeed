//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import Foundation

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate
    where View.Image == Image
{
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model

        cancellable = imageLoader(model.url).sink { [weak self] completion in
            switch completion {
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            default:
                break
            }
        } receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        }
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
