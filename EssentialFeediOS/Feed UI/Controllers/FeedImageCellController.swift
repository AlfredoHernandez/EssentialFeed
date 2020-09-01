//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class FeedImageCellController: FeedImageView {
    private lazy var cell = FeedImageCell()
    
    let presenter: FeedImagePresenter<FeedImageCellController,UIImage>

    init(presenter: FeedImagePresenter<FeedImageCellController,UIImage>) {
        self.presenter = presenter
    }

    func view() -> UITableViewCell {
        presenter.loadImage()
        return cell
    }

    func preload() {
        presenter.preload()
    }

    func cancelLoad() {
        presenter.cancelLoad()
    }
    
    func display(_ viewModel: ViewModel<UIImage>) {
        cell.locationContainer.isHidden = viewModel.location == nil
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = presenter.loadImage
    }
}
