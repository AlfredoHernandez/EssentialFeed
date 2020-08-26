//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class FeedImageCellController {
    let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.feedImageContainer.startShimmering()
        cell.feedImageRetryButton.isHidden = true
        cell.descriptionLabel.text = viewModel.imageDescription
        cell.locationLabel.text = viewModel.imageLocation
        cell.locationContainer.isHidden = (viewModel.imageLocation == nil)
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
            cell?.feedImageRetryButton.isHidden = (image != nil)
            cell?.feedImageContainer.stopShimmering()
        }
        cell.onRetry = viewModel.loadImage
        viewModel.loadImage()
        return cell
    }
    
    func preload() {
        viewModel.preload()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
}
