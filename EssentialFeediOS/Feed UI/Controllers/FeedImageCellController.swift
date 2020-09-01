//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()

    let delegate: FeedImageCellControllerDelegate

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }

    func display(_ viewModel: ViewModel<UIImage>) {
        cell.locationContainer.isHidden = viewModel.location == nil
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
}
