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
    
    func loadImage() {
        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            self?.onImageLoad?(image)
        }
    }
    
    var imageDescription: String? { model.description }
    var imageLocation: String? { model.location }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
