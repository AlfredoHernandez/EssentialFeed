//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()

    let loadImage: () -> Void
    let preload: () -> Void
    let cancelLoad: () -> Void

    init(loadImage: @escaping () -> Void, preload: @escaping () -> Void, cancelLoad: @escaping () -> Void) {
        self.loadImage = loadImage
        self.preload = preload
        self.cancelLoad = cancelLoad
    }

    func view() -> UITableViewCell {
        loadImage()
        return cell
    }

    func display(_ viewModel: ViewModel<UIImage>) {
        cell.locationContainer.isHidden = viewModel.location == nil
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = loadImage
    }
}
