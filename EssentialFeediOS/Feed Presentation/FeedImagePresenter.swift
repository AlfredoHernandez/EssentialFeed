//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import Foundation

struct ViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
}

protocol FeedImageView: class {
    associatedtype Image
    func display(_ viewModel: ViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: (Data) -> Image?
    weak var view: View?

    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view?.display(
            ViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view?.display(
            ViewModel(
                description: model.description,
                location: model.location,
                image: image,
                isLoading: true,
                shouldRetry: false
            )
        )
    }

    func didFinishLoadingImageData(with _: Error, for model: FeedImage) {
        view?.display(
            ViewModel(
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
