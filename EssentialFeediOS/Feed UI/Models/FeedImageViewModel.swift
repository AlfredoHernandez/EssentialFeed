//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import UIKit

final class FeedImageViewModel {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var onImageLoad: ((UIImage?) -> Void)?
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            self?.onImageLoad?(image)
            self?.onShouldRetryImageLoadStateChange?(image == nil)
            self?.onImageLoadingStateChange?(false)
        }
    }
    
    var imageDescription: String? { model.description }
    var imageLocation: String? { model.location }
    var hasLocation: Bool { imageLocation != nil }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
