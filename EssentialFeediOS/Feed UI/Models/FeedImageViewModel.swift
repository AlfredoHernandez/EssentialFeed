//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import UIKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    var onImageLoad: Observer<UIImage?>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let data = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(data)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    var description: String? { model.description }
    var location: String? { model.location }
    var hasLocation: Bool { location != nil }

    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }

    func cancelLoad() {
        task?.cancel()
    }
}
